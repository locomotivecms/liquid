require 'spec_helper'

describe "Liquid Rendering" do
  describe "for loops" do

    describe "for" do
      describe "{% for item in collection %}" do
        it "should repeat the block for each item in the collection" do
          data = {'collection' => [1,2,3,4]}
          render('{%for item in collection%} yo {%endfor%}', data).should == ' yo  yo  yo  yo '

          data = {'collection' => [1,2]}
          render('{%for item in collection%}yo{%endfor%}', data).should == 'yoyo'

          data = {'collection' => [1]}
          render('{%for item in collection%} yo {%endfor%}', data).should == ' yo '

          data = {'collection' => [1,2]}
          render('{%for item in collection%}{%endfor%}', data).should == ''

          data = {'collection' => [1,2,3]}
          render('{%for item in collection%} yo {%endfor%}', data).should == " yo  yo  yo "
        end

        it "should allow access to the current item via {{item}}" do
          data = {'collection' => [1,2,3]}
          render('{%for item in collection%} {{item}} {%endfor%}', data).should == ' 1  2  3 '
          render('{% for item in collection %}{{item}}{% endfor %}', data).should == '123'
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == '123'

          data = {'collection' => ['a','b','c','d']}
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == 'abcd'

          data = {'collection' => ['a',' ','b',' ','c']}
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == 'a b c'

          data = {'collection' => ['a','','b','','c']}
          render('{%for item in collection%}{{item}}{%endfor%}', data).should == 'abc'
        end

        it "should allow deep nesting" do
          data = {'array' => [[1,2],[3,4],[5,6]] }
          render('{%for item in array%}{%for i in item%}{{ i }}{%endfor%}{%endfor%}', data).should == '123456'
        end

        it "should expose {{forloop.name}} to get the name of the collection" do
          data = {'collection' => [1] }
          render("{%for item in collection%} {{forloop.name}} {%endfor%}", data).should == " item-collection "
        end

        it "should expose {{forloop.length}} for the overall size of the collection being looped" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.length}} {%endfor%}", data).should == " 3  3  3 "
        end

        it "should expose {{forloop.index}} for the current item's position in the collection (1 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.index}} {%endfor%}", data).should == " 1  2  3 "
        end

        it "should expose {{forloop.index0}} for the current item's position in the collection (0 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.index0}} {%endfor%}", data).should == " 0  1  2 "
        end

        it "should expose {{forloop.rindex}} for the number of items remaining in the collection (1 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.rindex}} {%endfor%}", data).should == " 3  2  1 "
        end

        it "should expose {{forloop.rindex0}} for the number of items remaining in the collection (0 based)" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {{forloop.rindex0}} {%endfor%}", data).should == " 2  1  0 "
        end

        it "should expose {{forloop.first}} for the first item in the collection" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {% if forloop.first %}y{% else %}n{% endif %} {%endfor%}", data).should == " y  n  n "
        end

        it "should expose {{forloop.last}} for the last item in the collection" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection%} {% if forloop.last %}y{% else %}n{% endif %} {%endfor%}", data).should == " n  n  y "
        end
      end

      describe "{% for item in collection reversed %}" do
        it "should reverse the loop" do
          data = {'collection' => [1,2,3] }
          render("{%for item in collection reversed%}{{item}}{%endfor%}", data).should == "321"
        end
      end

      context "with limit and offset" do
        let(:data) do
          {'collection' => [1,2,3,4,5,6,7,8,9,0] }
        end

        describe "{% for item in collection limit: 4 %}" do
          it "should only cycle through the first 4 items of the collection" do
            render("{%for item in collection limit:4%}{{item}}{%endfor%}", data).should  == "1234"
            render("{%for item in collection limit: 4%}{{item}}{%endfor%}", data).should == "1234"
          end
        end

        describe "{% for item in collection offset:8 %}" do
          it "should cycle throughthe collection starting on the 9th item" do
            render("{%for item in collection offset:8%}{{item}}{%endfor%}", data).should  == "90"
          end
        end

        describe "{% for item in collection limit:4 offset:2}" do
          it "should only cycle through the 4 items of the collection, starting on the 3rd item" do
            render("{%for item in collection limit:4 offset:2 %}{{item}}{%endfor%}", data).should == "3456"
            render("{%for item in collection limit: 4 offset: 2 %}{{item}}{%endfor%}", data).should == "3456"
          end

          it "{% for item in collection limit:limit offset:offset}" do
            data.merge! 'limit' => '4', 'offset' => '2'
            render("{%for item in collection limit:limit offset:offset %}{{item}}{%endfor%}", data).should == "3456"
            render("{%for item in collection limit: limit offset: offset %}{{item}}{%endfor%}", data).should == "3456"
          end
        end

        describe "{% for item in collection offset:continue limit: 3}" do
          it "should resume the iteration from where it ended earlier" do

            output = render multiline_string(<<-END), data
            | {%for i in collection limit:3 %}{{i}}{%endfor%}
            | next
            | {%for i in collection offset:continue limit:3 %}{{i}}{%endfor%}
            | next
            | {%for i in collection offset:continue limit:3 %}{{i}}{%endfor%}
            END

            output.should == multiline_string(<<-END)
            | 123
            | next
            | 456
            | next
            | 789
            END
          end
        end


        describe "edge cases" do
          context "limit: -1" do
            it "should ignore the limit" do
              render("{%for item in collection limit:-1 offset:5 %}{{item}}{%endfor%}", data).should == ""
            end
          end

          context "offset: -1" do
            it "should ignore the offset" do
              render("{%for item in collection limit:1 offset:-1 %}{{item}}{%endfor%}", data).should == ""
            end
          end

          context "offset: 100" do
            it "should render an empty string" do
              render("{%for item in collection limit:1 offset:100 %} {{item}} {%endfor%}", data).should == ""
            end
          end

          context "resume with big limit" do
            it "should complete the rest of the items" do
              output = render multiline_string(<<-END), data
              | {%for i in collection limit:3 %}{{i}}{%endfor%}
              | next
              | {%for i in collection offset:continue limit:10000 %}{{i}}{%endfor%}
              END

              output.should == multiline_string(<<-END)
              | 123
              | next
              | 4567890
              END
            end
          end

          context "resume with big offset" do
            it "should complete the rest of the items" do
              output = render multiline_string(<<-END), data
              | {%for i in collection limit:3 %}{{i}}{%endfor%}
              | next
              | {%for i in collection offset:continue offset:10000 %}{{i}}{%endfor%}
              END

              output.should == multiline_string(<<-END)
              | 123
              | next
              | |
              END
            end
          end
        end
      end

      context "{% for item in (1..3) %}" do
        it "should repeat the block for each item in the range" do
          render('{%for item in (1..3) %} {{item}} {%endfor%}').should == ' 1  2  3 '
        end
      end

      context "{% ifchanged %}" do
        it "should render the block only if the for item is different than the last" do
          data = {'array' => [ 1, 1, 2, 2, 3, 3] }
          render('{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',data).should == '123'

          data = {'array' => [ 1, 1, 1, 1] }
          render('{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}',data).should == '1'
        end
      end
    end

    describe "{% assign %}" do

      it "should assign a variable to a string" do
        render('{%assign var = "yo" %} var:{{var}} ').should == " var:yo "
        render("{%assign var = 'yo' %} var:{{var}} ").should == " var:yo "
        render("{%assign var='yo' %} var:{{var}} ").should == " var:yo "
        render("{%assign var='yo'%} var:{{var}} ").should == " var:yo "

        render('{%assign var="" %} var:{{var}} ').should == " var: "
        render("{%assign var='' %} var:{{var}} ").should == " var: "
      end

      it "should assign a variable to an integer" do
        render('{%assign var = 1 %} var:{{var}} ').should == " var:1 "
        render("{%assign var=1 %} var:{{var}} ").should == " var:1 "
        render("{%assign var =1 %} var:{{var}} ").should == " var:1 "
      end

      it "should assign a variable to a float" do
        render('{%assign var = 1.011 %} var:{{var}} ').should == " var:1.011 "
        render("{%assign var=1.011 %} var:{{var}} ").should == " var:1.011 "
        render("{%assign var =1.011 %} var:{{var}} ").should == " var:1.011 "
      end

      it "should assign a variable that includes a hyphen" do
        render('{%assign a-b = "yo" %} {{a-b}} ').should == " yo "
        render('{{a-b}}{%assign a-b = "yo" %} {{a-b}} ').should == " yo "
        render('{%assign a-b = "yo" %} {{a-b}} {{a}} {{b}} ', 'a' => 1, 'b' => 2).should == " yo 1 2 "
      end

      it "should assign a variable to a complex accessor" do
        data = {'var' => {'a:b c' => {'paged' => '1' }}}
        render('{%assign var2 = var["a:b c"].paged %}var2: {{var2}}', data).should == 'var2: 1'
      end

      it "should assign var2 to 'hello' when var is 'hello'" do
        data = {'var' => 'Hello' }
        render('var2:{{var2}} {%assign var2 = var%} var2:{{var2}}',data).should == 'var2:  var2:Hello'
      end

      it "should assign the variable in a global context, even if it is in a block" do
        render( '{%for i in (1..2) %}{% assign a = "variable"%}{% endfor %}{{a}}'  ).should == "variable"
      end
    end

    context "{% capture %}" do
      it "should capture the result of a block into a variable" do
        data = {'var' => 'content' }
        render('{{ var2 }}{% capture var2 %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}', data).should == 'content foo content foo '
      end

      it "should throw an error when it detects bad syntax" do
        data = {'var' => 'content'}
        expect {
          render('{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}', data)
        }.to raise_error(Liquid::SyntaxError)
      end
    end

    context "{% case %}" do
      it "should render the first block with a matching {% when %} argument" do
        data = {'condition' => 1 }
        render('{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}', data).should == ' its 1 '

        data = {'condition' => 2 }
        render('{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}', data).should == ' its 2 '

        # dont render whitespace between case and first when
        data = {'condition' => 2 }
        render('{% case condition %} {% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}', data).should == ' its 2 '
      end

      it "should match strings correctly" do
        data = {'condition' => "string here" }
        render('{% case condition %}{% when "string here" %} hit {% endcase %}', data).should == ' hit '

        data = {'condition' => "bad string here" }
        render('{% case condition %}{% when "string here" %} hit {% endcase %}', data).should == ''
      end

      it "should not render anything if no matches found" do
        data = {'condition' => 3 }
        render(' {% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %} ', data).should == '  '
      end

      it "should evaluate variables and expressions" do
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => []).should == ''
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1]).should == '1'
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1]).should == '2'
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1]).should == ''
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1, 1]).should == ''
        render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}', 'a' => [1, 1, 1, 1, 1]).should == ''
      end

      it "should allow assignment from within a {% when %} block" do
        # Example from the shopify forums
        template = %q({% case collection.handle %}{% when 'menswear-jackets' %}{% assign ptitle = 'menswear' %}{% when 'menswear-t-shirts' %}{% assign ptitle = 'menswear' %}{% else %}{% assign ptitle = 'womenswear' %}{% endcase %}{{ ptitle }})

        render(template, "collection" => {'handle' => 'menswear-jackets'}).should == 'menswear'
        render(template, "collection" => {'handle' => 'menswear-t-shirts'}) == 'menswear'
        render(template, "collection" => {'handle' => 'x'}) == 'womenswear'
        render(template, "collection" => {'handle' => 'y'}) == 'womenswear'
        render(template, "collection" => {'handle' => 'z'}) == 'womenswear'
      end

      it "should allow the use of 'or' to chain parameters with {% when %}" do
        template = '{% case condition %}{% when 1 or 2 or 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, {'condition' => 1 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 2 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 3 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 4 }).should == ' its 4 '
        render(template, {'condition' => 5 }).should == ''

        template = '{% case condition %}{% when 1 or "string" or null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, 'condition' => 1).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'string').should == ' its 1 or 2 or 3 '
        render(template, 'condition' => nil).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'something else').should == ''
      end

      it "should allow the use of commas to chain parameters with {% when %} " do
        template = '{% case condition %}{% when 1, 2, 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, {'condition' => 1 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 2 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 3 }).should == ' its 1 or 2 or 3 '
        render(template, {'condition' => 4 }).should == ' its 4 '
        render(template, {'condition' => 5 }).should == ''

        template = '{% case condition %}{% when 1, "string", null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}'
        render(template, 'condition' => 1).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'string').should == ' its 1 or 2 or 3 '
        render(template, 'condition' => nil).should == ' its 1 or 2 or 3 '
        render(template, 'condition' => 'something else').should == ''
      end

      it "should raise an error when theres bad syntax" do
        expect {
          render!('{% case false %}{% when %}true{% endcase %}')
        }.to raise_error(Liquid::SyntaxError)

        expect {
          render!('{% case false %}{% huh %}true{% endcase %}')
        }.to raise_error(Liquid::SyntaxError)
      end

      context "with {% else %}" do
        it "should render the {% else %} block when no matches found" do
          data = {'condition' => 5 }
          render('{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}', data).should == ' hit '

          data = {'condition' => 6 }
          render('{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}', data).should == ' else '
        end

        it "should evaluate variables and expressions" do
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => []).should == 'else'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1]).should == '1'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1]).should == '2'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1, 1]).should == 'else'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1, 1, 1]).should == 'else'
          render('{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}', 'a' => [1, 1, 1, 1, 1]).should == 'else'


          render('{% case a.empty? %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "else"
          render('{% case false %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "false"
          render('{% case true %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "true"
          render('{% case NULL %}{% when true %}true{% when false %}false{% else %}else{% endcase %}', {}).should == "else"

        end
      end
    end

    context "{% cycle %}" do

      it "should cycle through a list of strings" do
        render('{%cycle "one", "two"%}').should == 'one'
        render('{%cycle "one", "two"%} {%cycle "one", "two"%}').should == 'one two'
        render('{%cycle "", "two"%} {%cycle "", "two"%}').should == ' two'
        render('{%cycle "one", "two"%} {%cycle "one", "two"%} {%cycle "one", "two"%}').should == 'one two one'
        render('{%cycle "text-align: left", "text-align: right" %} {%cycle "text-align: left", "text-align: right"%}').should == 'text-align: left text-align: right'
      end

      it "should keep track of multiple cycles" do
        render('{%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%}').should == '1 2 1 1 2 3 1'
      end

      it "should keep track of multiple named cycles" do
        render('{%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %}').should == 'one one two two one one'
      end

      it "should allow multiple named cycles with names from context" do
        data = {"var1" => 1, "var2" => 2 }
        render('{%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %}', data).should == 'one one two two one one'
      end
    end


  end
end