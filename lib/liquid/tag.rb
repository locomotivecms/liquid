module Liquid

  class Tag

    attr_accessor :nodelist, :context

    def initialize(tag_name, markup, tokens, context)
      @tag_name   = tag_name
      @markup     = markup
      @context    = context
      parse(tokens)
    end

    def parse(tokens)
    end

    def name
      self.class.name.downcase
    end

    def render(context)
      ''
    end

  end # Tag

end # Tag
