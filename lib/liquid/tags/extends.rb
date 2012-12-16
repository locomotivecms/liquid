module Liquid

  # Extends allows designer to use template inheritance
  #
  #   {% extends home %}
  #   {% block content }Hello world{% endblock %}
  #
  class Extends < Block
    Syntax = /(#{QuotedFragment}+)/

    def initialize(tag_name, markup, tokens, context)
      if markup =~ Syntax
        @template_name = $1.gsub(/["']/o, '').strip
      else
        raise SyntaxError.new("Error in tag 'extends' - Valid syntax: extends [template]")
      end

      @context = context

      @parent_template = parse_parent_template

      prepare_parsing

      super

      end_tag
    end

    def prepare_parsing
      @context.merge!(:blocks => self.find_blocks(@parent_template.root.nodelist))
    end

    def end_tag
      # replace the nodelist by the new one
      @nodelist = @parent_template.root.nodelist.clone

      @parent_template = nil # no need to keep it
    end

    protected

    def find_blocks(nodelist, blocks = {})
      if nodelist && nodelist.any?
        0.upto(nodelist.size - 1).each do |index|
          node = nodelist[index]

          if node.respond_to?(:call_super) # inherited block !
            new_node = node.class.clone_block(node)

            nodelist.insert(index, new_node)
            nodelist.delete_at(index + 1)

            blocks[node.name] = new_node
          end
          if node.respond_to?(:nodelist)
            self.find_blocks(node.nodelist, blocks) # FIXME: find nested blocks too
          end
        end
      end
      blocks
    end

    private

    def parse_parent_template
      source = Template.file_system.read_template_file(@template_name)
      Template.parse(source)
    end

    def assert_missing_delimitation!
    end
  end

  Template.register_tag('extends', Extends)
end