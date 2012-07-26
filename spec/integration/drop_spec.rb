require 'spec_helper'

require 'drops/product_drop'
require 'drops/context_drop'
require 'drops/enumerable_drop'

describe "Liquid Rendering" do
  describe "Drops" do

    it "allow rendering with a product" do
      lambda {
        Liquid::Template.parse('  ').render('product' => ProductDrop.new)
      }.should_not raise_error
    end

    it "should render drops within drops" do
      template = Liquid::Template.parse ' {{ product.texts.text }} '
      template.render('product' => ProductDrop.new).should == ' text1 '
    end

    it "should render the text returned from a catchall method" do
      template = Liquid::Template.parse ' {{ product.catchall.unknown }} '
      template.render('product' => ProductDrop.new).should == ' method: unknown '
    end

    it "should cycle through an array of text" do
      template = Liquid::Template.parse multiline_string(<<-END_LIQUID)
      |  {% for text in product.texts.array %} {{text}} {% endfor %}
      END_LIQUID

      template.render('product' => ProductDrop.new).strip.should == "text1  text2"
    end

    it "should not allow protected methods to be called" do
      template = Liquid::Template.parse(' {{ product.callmenot }} ')

      template.render('product' => ProductDrop.new).should == "  "

    end

    describe "context" do
      it "should allow using the context within a drop" do
        template = Liquid::Template.parse(' {{ context.read_bar }} ')
        data = {"context" => ContextDrop.new, "bar" => "carrot"}

        template.render(data).should == " carrot "
      end

      it "should allow the use of context within nested drops" do
        template = Liquid::Template.parse(' {{ product.context.read_foo }} ')
        data = {"product" => ProductDrop.new, "foo" => "monkey"}

        template.render(data).should == " monkey "
      end
    end

    describe "scope" do

      it "should allow access to context scope from within a drop" do
        template = Liquid::Template.parse('{{ context.count_scopes }}')
        template.render("context" => ContextDrop.new).should == "1"

        template = Liquid::Template.parse('{%for i in dummy%}{{ context.count_scopes }}{%endfor%}')
        template.render("context" => ContextDrop.new, 'dummy' => [1]).should == "2"

        template = Liquid::Template.parse('{%for i in dummy%}{%for i in dummy%}{{ context.count_scopes }}{%endfor%}{%endfor%}')
        template.render("context" => ContextDrop.new, 'dummy' => [1]).should == "3"
      end

      it "should allow access to context scope from within a drop through a scope" do
        template = Liquid::Template.parse( '{{ s }}'  )
        template.render('context' => ContextDrop.new,
                        's' => Proc.new{|c| c['context.count_scopes'] }).should == "1"

        template = Liquid::Template.parse( '{%for i in dummy%}{{ s }}{%endfor%}'  )
        template.render('context' => ContextDrop.new,
                        's' => Proc.new{|c| c['context.count_scopes']},
                        'dummy' => [1]).should == "2"

        template = Liquid::Template.parse( '{%for i in dummy%}{%for i in dummy%}{{ s }}{%endfor%}{%endfor%}'  )
        template.render('context' => ContextDrop.new,
                        's' => Proc.new{|c| c['context.count_scopes'] },
                        'dummy' => [1]).should == "3"
      end

      it "should allow access to assigned variables through as scope" do
        template = Liquid::Template.parse( '{% assign a = "variable"%}{{context.a}}'  )
        template.render('context' => ContextDrop.new).should == "variable"

        template = Liquid::Template.parse( '{% assign a = "variable"%}{%for i in dummy%}{{context.a}}{%endfor%}'  )
        template.render('context' => ContextDrop.new, 'dummy' => [1]).should == "variable"

        template = Liquid::Template.parse( '{% assign header_gif = "test"%}{{context.header_gif}}'  )
        template.render('context' => ContextDrop.new).should == "test"

        template = Liquid::Template.parse( "{% assign header_gif = 'test'%}{{context.header_gif}}"  )
        template.render('context' => ContextDrop.new).should == "test"
      end

      it "should allow access to scope from within tags" do
        template = Liquid::Template.parse( '{% for i in context.scopes_as_array %}{{i}}{% endfor %}' )
        template.render('context' => ContextDrop.new, 'dummy' => [1]).should == "1"

        template = Liquid::Template.parse( '{%for a in dummy%}{% for i in context.scopes_as_array %}{{i}}{% endfor %}{% endfor %}'  )
        template.render('context' => ContextDrop.new, 'dummy' => [1]).should == "12"

        template = Liquid::Template.parse( '{%for a in dummy%}{%for a in dummy%}{% for i in context.scopes_as_array %}{{i}}{% endfor %}{% endfor %}{% endfor %}'  )
        template.render('context' => ContextDrop.new, 'dummy' => [1]).should == "123"
      end

      it "should allow access to the forloop index within a drop" do
        template = Liquid::Template.parse( '{%for a in dummy%}{{ context.loop_pos }}{% endfor %}'  )
        template.render('context' => ContextDrop.new, 'dummy' => ["first","second","third"]).should == "123"
      end
    end

    context "enumerable drop" do

      it "should allow iteration through the drop" do
        template = Liquid::Template.parse( '{% for c in collection %}{{c}}{% endfor %}')
        template.render('collection' => EnumerableDrop.new).should == "123"
      end

      it "should return the drops size" do
        template = Liquid::Template.parse( '{{collection.size}}')
        template.render('collection' => EnumerableDrop.new).should == "3"
      end

    end

  end
end

