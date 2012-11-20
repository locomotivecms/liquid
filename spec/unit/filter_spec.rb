require 'spec_helper'

module Liquid
  describe StandardFilters do

    class TestFilters
      include StandardFilters
    end

    let(:filters) do
      TestFilters.new
    end

    context "#size" do
      it "should return the size of the collection" do
        filters.size([1,2,3]).should == 3
        filters.size([]).should == 0
      end

      it "should return 0 for nil" do
        filters.size(nil).should == 0
      end
    end

    context "#downcase" do
      it "should make the string lower case" do
        filters.downcase("Testing").should == "testing"
      end

      it "should return empty string for nil" do
        filters.downcase(nil).should == ""
      end
    end

    context "#upcase" do
      it "should make the string upper case" do
        filters.upcase("Testing").should == "TESTING"
      end

      it "should return empty string for nil" do
        filters.upcase(nil).should == ""
      end
    end

    context "#truncate" do
      it "should truncate string to the specified length, replacing with ellipsis" do
        filters.truncate('1234567890', 7).should == '1234...'
        filters.truncate('1234567890', 20).should == '1234567890'
        filters.truncate('1234567890', 0).should == '...'
      end

      it "should not truncate if no length is passed in" do
        filters.truncate('1234567890').should == '1234567890'
      end

      it "should allow overriding of the truncate character" do
        filters.truncate('1234567890', 7, '---').should == '1234---'
        filters.truncate('1234567890', 7, '--').should == '12345--'
        filters.truncate('1234567890', 7, '-').should == '123456-'
      end
    end

    context "#escape" do
      it "should escape html characters" do
        filters.escape('<strong>').should == '&lt;strong&gt;'
      end

      it "should be aliased with 'h'" do
        filters.h('<strong>').should == '&lt;strong&gt;'
      end
    end

    context "#truncateword" do
      it "should truncate the string to the amount of words specified" do
        filters.truncatewords('one two three', 4).should == 'one two three'

        filters.truncatewords('one two three', 2).should == 'one two...'
      end

      it "should be ignored if no length is specified" do
        filters.truncatewords('one two three').should == 'one two three'
      end

      it "should work with crazy special characters" do
        filters.truncatewords('Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221; x 16&#8221; x 10.5&#8221; high) with cover.', 15).should ==
                              'Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221;...'

      end
    end

    context "#split" do

      it "should split the given string into an array based on the given delimeter" do
        filters.split("red|green|blue", "|").should == ['red', 'green', 'blue']
      end

    end

    context "#strip_html" do
      it "should strip out the html tags but leave the content" do
        filters.strip_html("<div>test</div>").should == "test"
        filters.strip_html("<div id='test'>test</div>").should == "test"
      end

      it "should completely remove the content of script tags" do
        filters.strip_html("<script type='text/javascript'>document.write('some stuff');</script>").should == ''
      end

      it "should return empty string for nil" do
        filters.strip_html(nil).should == ''
      end
    end

    context "#join" do
      it "should default to joining an array by a space" do
        filters.join([1,2,3,4]).should == "1 2 3 4"
      end

      it "should allow you to specify the join character" do
        filters.join([1,2,3,4], ' - ').should == "1 - 2 - 3 - 4"
      end

      it "should join a hash" do
        output = filters.join({"one" => 1, "two" => 2})
        output.should include("one 1")
        output.should include("two 2")
      end

      it "should join a hash with a character" do
        output = filters.join({"one" => 1, "two" => 2}, ' - ')
        output.should include("one - 1")
        output.should include("two - 2")
      end

      it "should join a hash with separate characters for fields, and keys" do
        output = filters.join({"one" => 1, "two" => 2}, '|', '-')
        output.should include("one-1")
        output.should include("two-2")
      end
    end

    context "#sort" do
      it "should sort an array" do
        filters.sort([4,3,2,1]).should == [1,2,3,4]
      end
    end

    context "#map" do
      it "should return a list of values that have a key matching the argument" do
        filters.map([{"a" => 1}, {"a" => 2}, {"a" => 3}, {"a" => 4}], 'a').should == [1,2,3,4]

        data = {'ary' => [{'foo' => {'bar' => 'a'}}, {'foo' => {'bar' => 'b'}}, {'foo' => {'bar' => 'c'}}]}
        render("{{ ary | map:'foo' | map:'bar' }}", data).should == "abc"
      end
    end

    context "#date" do
      it "should format a date using a specified format string" do
        filters.date(Time.parse("2006-05-05 10:00:00"), "%B").should == 'May'
        filters.date(Time.parse("2006-06-05 10:00:00"), "%B").should == 'June'
        filters.date(Time.parse("2006-07-05 10:00:00"), "%B").should == 'July'

        filters.date("2006-05-05 10:00:00", "%B").should == 'May'
        filters.date("2006-06-05 10:00:00", "%B").should == 'June'
        filters.date("2006-07-05 10:00:00", "%B").should == 'July'

        filters.date("2006-07-05 10:00:00", "").should == '2006-07-05 10:00:00'
        filters.date("2006-07-05 10:00:00", nil).should == '2006-07-05 10:00:00'

        filters.date("2006-07-05 10:00:00", "%m/%d/%Y").should == '07/05/2006'

        filters.date("Fri Jul 16 01:00:00 2004", "%m/%d/%Y").should == "07/16/2004"
      end
    end

    context "#first" do
      it "should return the first item in an array" do
        filters.first([1,2,3]).should == 1
      end

      it "should return nil for an empty array" do
        filters.first([]).should == nil
      end
    end

    context "#last" do
      it "should return the last item in an array" do
        filters.last([1,2,3]).should == 3
      end

      it "should return nil for an empty array" do
        filters.last([]).should == nil
      end
    end

    context "#replace" do
      it "should replace all matches in a string with the new string" do
        filters.replace("a a a a", 'a', 'b').should == 'b b b b'
        render("{{ 'a a a a' | replace: 'a', 'b' }}").should == "b b b b"
      end
    end

    context "#replace_first" do
      it "should replace the first match in a string with the new string" do
        filters.replace_first("a a a a", 'a', 'b').should == 'b a a a'
        render("{{ 'a a a a' | replace_first: 'a', 'b' }}").should == "b a a a"
      end
    end

    context "#remove" do
      it "should remove all matching strings" do
        filters.remove("a a a a", 'a').should == '   '
        render("{{ 'a a a a' | remove: 'a' }}").should == "   "
      end
    end

    context "#remove_first" do
      it "should remove the first matching string" do
        filters.remove_first("a a a a", 'a').should == ' a a a'
        filters.remove_first("a a a a", 'a ').should == 'a a a'
        render("{{ 'a a a a' | remove_first: 'a' }}").should == ' a a a'
      end
    end

  end
end