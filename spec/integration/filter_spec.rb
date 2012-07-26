require 'spec_helper'

describe "Liquid Rendering" do
  describe "Filters" do
    before(:each) do
      @context = Liquid::Context.new
    end

    def render_variable(body)
      Liquid::Variable.new(body).render(@context)
    end

    context "standard filters" do
      describe "size" do
        it "should return the size of a string" do
          @context['val'] = "abcd"
          render_variable('val | size').should == 4
        end

        it "should return the size of an array" do
          @context['val'] = [1,2,3,4]
          render_variable('val | size').should == 4
        end

        it "should return the size of a hash" do
          @context['val'] = {"one" => 1, "two" => 2, "three" => 3, "four" => 4}
          render_variable('val | size').should == 4
        end
      end

      describe "join" do
        it "should join an array" do
          @context['val'] = [1,2,3,4]
          render_variable('val | join').should == "1 2 3 4"
        end

        it "should join a hash" do
          @context['val'] = {"one" => 1}
          render_variable('val | join').should == "one 1"

          @context['val'] = {"two" => 2, "one" => 1}
          output = render_variable('val | join: ":"')
          output.should == "two:2:one:1"
        end

        it "should join a hash with custom field and value separators" do
          @context['val'] = {"one" => 1}
          render_variable('val | join').should == "one 1"

          @context['val'] = {"two" => 2, "one" => 1}
          output = render_variable('val | join: "|", ":"')
          output.should == "two:2|one:1"
        end


        it "should join a string" do
          @context['val'] = "one"
          render_variable('val | join').should == "one"
        end
      end

      describe "sort" do
        it "should sort a single value" do
          @context['value'] = 3
          render_variable("value | sort").should == [3]
        end

        it "should sort an array of numbers" do
          @context['numbers'] = [2,1,4,3]
          render_variable("numbers | sort").should == [1,2,3,4]
        end

        it "should sort an array of words" do
          @context['words'] = ['expected', 'as', 'alphabetic']
          render_variable("words | sort").should == ['alphabetic', 'as', 'expected']
        end

        it "should sort an array of arrays" do
          @context['arrays'] = [['flattened'], ['are']]
          render_variable('arrays | sort').should == ['are', 'flattened']
        end
      end

      describe "strip_html" do
        it "should strip out tags around a <b>" do
          @context['user_input'] = "<b>bla blub</a>"
          render_variable('user_input | strip_html').should == "bla blub"
        end

        it "should remove script tags entirely" do
          @context['user_input'] = "<script>alert('OMG hax!')</script>"
          render_variable('user_input | strip_html').should == ""
        end
      end

      describe "capitalize" do
        it "should capitalize the first character" do
          @context['val'] = "blub"
          render_variable('val | capitalize').should == 'Blub'
        end
      end

      describe "strip_newlines" do
        it "should remove newlines from a string" do
          @context['source'] = "a\nb\nc"
          render_variable('source | strip_newlines').should == 'abc'
        end
      end

      describe "newline_to_br" do
        it "should convert line breaks to html <br>'s" do
          @context['source'] = "a\nb\nc"
          render_variable('source | newline_to_br').should == "a<br />\nb<br />\nc"
        end
      end

      describe "plus" do
        it "should increment a number by the specified amount" do
          @context['val'] = 1
          render_variable('val | plus:1').should == 2

          @context['val'] = "1"
          render_variable('val | plus:1').should == 2

          @context['val'] = "1"
          render_variable('val | plus:"1"').should == 2
        end
      end

      describe "minus" do
        it "should decrement a number by the specified amount" do
          @context['val'] = 2
          render_variable('val | minus:1').should == 1

          @context['val'] = "2"
          render_variable('val | minus:1').should == 1

          @context['val'] = "2"
          render_variable('val | minus:"1"').should == 1
        end
      end

      describe "times" do
        it "should multiply a number by the specified amount" do
          @context['val'] = 2
          render_variable('val | times:2').should == 4

          @context['val'] = "2"
          render_variable('val | times:2').should == 4

          @context['val'] = "2"
          render_variable('val | times:"2"').should == 4
        end
      end

      describe "divided_by" do
        it "should divide a number the specified amount" do
          @context['val'] = 12
          render_variable('val | divided_by:3').should == 4
        end

        it "should chop off the remainder when dividing by an integer" do
          @context['val'] = 14
          render_variable('val | divided_by:3').should == 4
        end

        it "should return a float when dividing by another float" do
          @context['val'] = 14
          render_variable('val | divided_by:3.0').should be_within(0.001).of(4.666)
        end

        it "should return an errorm essage if divided by 0" do
          @context['val'] = 5
          expect{
            render_variable('val | divided_by:0')
          }.to raise_error(ZeroDivisionError)
        end
      end

      describe "append" do
        it "should append a string to another string" do
          @context['val'] = "bc"
          render_variable('val | append: "d"').should == "bcd"

          @context['next'] = " :: next >>"
          render_variable('val | append: next').should == "bc :: next >>"
        end
      end

      describe "prepend" do
        it "should prepend a string onto another string" do
          @context['val'] = "bc"
          render_variable('val | prepend: "a"').should == "abc"

          @context['prev'] = "<< prev :: "
          render_variable('val | prepend: prev').should == "<< prev :: bc"
        end
      end
    end

    module MoneyFilter
      def money(input)
        sprintf('$%d', input)
      end

      def money_with_underscores(input)
        sprintf('_$%d_', input)
      end
    end

    module CanadianMoneyFilter
      def money(input)
        sprintf('$%d CAD', input)
      end
    end

    context "with custom filters added to context" do
      before(:each) do
        @context['val'] = 1000
      end

      it "should use the local filters" do
        @context.add_filters(MoneyFilter)
        render_variable('val | money').should == "$1000"
        render_variable('val | money_with_underscores').should == "_$1000_"
      end

      it "should allow filters to overwrite previous ones" do
        @context.add_filters(MoneyFilter)
        @context.add_filters(CanadianMoneyFilter)
        render_variable('val | money').should == "$1000 CAD"
      end
    end

    context "filters in template" do
      before(:each) do
        Liquid::Template.register_filter(MoneyFilter)
      end

      it "should use globally registered filters" do
        render('{{1000 | money}}').should == "$1000"
      end

      it "should allow custom filters to override registered filters" do
        Liquid::Template.parse('{{1000 | money}}').render(nil, :filters => CanadianMoneyFilter).should == "$1000 CAD"
        Liquid::Template.parse('{{1000 | money}}').render(nil, :filters => [CanadianMoneyFilter]).should == "$1000 CAD"
      end

      it "should allow pipes in string arguments" do
        render("{{ 'foo|bar' | remove: '|' }}").should == "foobar"
      end

      it "cannot access private methods" do
        render("{{ 'a' | to_number }}").should == "a"
      end

      it "should ignore nonexistant filters" do
        render("{{ val | xyzzy }}", 'val' => 1000).should == "1000"
      end
    end

  end
end