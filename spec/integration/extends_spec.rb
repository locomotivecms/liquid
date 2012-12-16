require 'spec_helper'

describe "Liquid Rendering" do
  describe "Template Inheritance" do
    before(:each) do
      @templates ||= {}
    end

    before(:each) do
      Liquid::Template.file_system = self
    end

    def read_template_file(template_path)
      @template_path ||= {}
      @templates[template_path] || raise("TestFileSystem Error: No template defined for #{template_path}")
    end

    it "should allow extending a path" do
      @templates['parent-template'] = "Hurrah!"

      output = render("{% extends parent-template %}")
      output.should == "Hurrah!"
    end

    it "should allow include blocks within the parent template" do
      @templates['partial1'] = "[Partial Content1]"
      @templates['partial2'] = "[Partial Content2]"
      @templates['parent-with-include'] = multiline_string(<<-END)
      | {% include 'partial1' %}
      | {% block thing %}{% include 'partial2' %}{% endblock %}
      END

      # check with overridden block
      output = render multiline_string(<<-END)
      | {% extends parent-with-include %}
      | {% block thing %}[Overridden Block]{% endblock %}
      END

      output.should == multiline_string(<<-END)
      | [Partial Content1]
      | [Overridden Block]
      END

      # check includes within the parent's default block
      output = render("{% extends parent-with-include %}")
      output.should == multiline_string(<<-END)
      | [Partial Content1]
      | [Partial Content2]
      END
    end

    it "should allow access to the context from the inherited template" do
      @templates['parent-with-variable'] = "Hello, {{ name }}!"

      output = render("{% extends parent-with-variable %}", 'name' => 'Joe')
      output.should == "Hello, Joe!"
    end

    it "should allow deep nesting of inherited templates" do
      @templates['parent-with-variable'] = "Hello, {{ name }}!!"
      @templates['parent-with-parent'] = "{% extends parent-with-variable %}"

      output = render("{% extends parent-with-parent %}", 'name' => 'Joe')
      output.should == "Hello, Joe!!"
    end

    describe "{% defaultcontent %}" do
      it "should allow me to render in all the nonblock wrapped content from a parent layout" do
        pending "how do i get the content?"

        @templates['parent-template'] = multiline_string(<<-END)
        | OUTSIDE {% defaultcontent %}
        END

        # with content
        template = Liquid::Template.parse "{% extends parent-template %} [INSIDE]"
        template.render.should == "OUTSIDE [INSIDE]"

        # without content
        template = Liquid::Template.parse "{% extends parent-template %}"
        template.render.should == "OUTSIDE "
      end
    end

    describe "inherited blocks" do
      before(:each) do
        @templates['base'] = "Output / {% block content %}Hello, World!{% endblock %}"
      end

      it "should allow overriding blocks from an inherited template" do
        output = render("{% extends base %}{% block content %}Hola, Mundo!{% endblock %}")
        output.should == 'Output / Hola, Mundo!'
      end

      it "should allow an overriding block to call super" do
        output = render("{% extends base %}{% block content %}Lorem ipsum: {{block.super}}{% endblock %}")
        output.should == 'Output / Lorem ipsum: Hello, World!'
      end

      it "should allow deep nested includes to call super within overriden blocks" do
        @templates['deep'] = "{% extends base %}{% block content %}Deep: {{block.super}}{% endblock %}"
        output = render("{% extends deep %}{% block content %}Lorem ipsum: {{block.super}}{% endblock %}")
        output.should == 'Output / Lorem ipsum: Deep: Hello, World!'

        @templates['nested_and_deep'] = "{% extends base %}{% block content %}Deep: {{block.super}} -{% block inner %}FOO{% endblock %}-{% endblock %}"
        output = render("{% extends nested_and_deep %}{% block content/inner %}BAR{% endblock %}")
        output.should == 'Output / Deep: Hello, World! -BAR-'
      end
    end

    describe "nested inherited blocks" do

      before(:each) do
        @templates['base'] = "Output / {% block content %}Hello, World!{% block tagline %}(My tagline){% endblock %}{% endblock %}"
      end

      it "should allow overriding blocks from an inherited template" do
        output = render("{% extends base %}{% block content %}Hola, Mundo!{% endblock %}")
        output.should == 'Output / Hola, Mundo!'
      end

      it "should allow overriding blocks from an inherited template" do
        output = render("{% extends base %}{% block content/tagline %}(new tagline){% endblock %}")
        output.should == 'Output / Hello, World!(new tagline)'
      end

    end

  end
end