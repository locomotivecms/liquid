require 'spec_helper'

describe "Liquid Rendering" do
  describe "statements" do
    let(:data) do
      {}
    end

    def render(*args)
      super("#{subject} true {% else %} false {% endif %}", data).strip
    end

    describe %| {% if true == true %} | do
      it{ render.should == "true" }
    end

    describe %| {% if true != true %} | do
      it{ render.should == "false" }
    end

    describe %| {% if 0 > 0 %} | do
      it{ render.should == "false" }
    end

    describe %| {% if 1 > 0 %} | do
      it{ render.should == "true" }
    end

    describe %| {% if 0 < 1 %} | do
      it{ render.should == "true" }
    end

    describe %| {% if 0 <= 0 %} | do
      it{ render.should == "true" }
    end

    describe %| {% if null <= 0 %} | do
      it{ render.should == "false" }
    end

    describe %| {% if 0 <= null %} | do
      it{ render.should == "false" }
    end

    describe %| {% if 0 >= 0 %} | do
      it{ render.should == "true" }
    end

    describe %| {% if 'test' == 'test' %} | do
      it{ render.should == "true" }
    end

    describe %| {% if 'test' != 'test' %} | do
      it{ render.should == "false" }
    end

    context 'when var is assigned to "hello there!"' do
      let(:data) do
        { 'var' => "hello there!" }
      end

      describe %| {% if var == "hello there!" %} | do
        it{ render.should == "true" }
      end

      describe %| {% if "hello there!" == var %} | do
        it{ render.should == "true" }
      end

      describe %| {% if var == 'hello there!' %} | do
        it{ render.should == "true" }
      end

      describe %| {% if 'hello there!' == var %} | do
        it{ render.should == "true" }
      end
    end

    context 'when array is assigned to []' do
      let(:data) do
        {'array' => ''}
      end
      describe %| {% if array == empty %} | do
        it{ render.should == "true" }
      end
    end


    context 'when array is assigned to [1,2,3]' do
      let(:data) do
        {'array' => [1,2,3]}
      end

      describe %| {% if array == empty %} | do
        it{ render.should == "false" }
      end
    end

    context "when var is assigned to nil" do
      let(:data) do
        {'var' => nil}
      end

      describe %| {% if var == nil %} | do
        it{ render.should == "true" }
      end

      describe %| {% if var == null %} | do
        it{ render.should == "true" }
      end
    end

    context "when var is assigned to 1" do
      let(:data) do
        {'var' => 1}
      end

      describe %| {% if var != nil %} | do
        it{ render.should == "true" }
      end

      describe %| {% if var != null %} | do
        it{ render.should == "true" }
      end
    end


  end
end