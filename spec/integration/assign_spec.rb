require 'spec_helper'

describe "Liquid Rendering" do
  describe "Assignment" do
    let(:template) do
      Liquid::Template.parse(eval(subject))
    end

    context %|with 'values' => ["foo", "bar", "baz"]| do
      let(:render_options) do
        {
          'values' => ["foo", "bar", "baz"]
        }
      end

      describe %!"{% assign foo = values | first %}.{{ foo }}."! do
        it{ template.render(render_options).should == '.foo.' }
      end

      describe %!"{% assign foo = values | first | capitalize %}.{{ foo }}."! do
        it{ template.render(render_options).should == '.Foo.' }
      end

      describe %|"{% assign foo = values %}.{{ foo[0] }}."| do
        it{ template.render(render_options).should == ".foo." }
      end

      describe %|"{% assign foo = values %}.{{ foo[1] }}."| do
        it{ template.render(render_options).should == ".bar." }
      end

      describe %|"{% assign foo = values %}.{{ foo[2] }}."| do
        it{ template.render(render_options).should == ".baz." }
      end
    end
  end
end
