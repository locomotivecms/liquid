require 'spec_helper'

module Liquid
  describe Tag do

    context "empty tag" do
      before(:each) do
        @tag = Tag.new('tag', [], [], {})
      end

      context "#name" do
        it "should return the name of the tag" do
          @tag.name.should == "liquid::tag"
        end
      end

      context "#render" do
        it "should render an empty string" do
          @tag.render(Context.new).should == ''
        end
      end
    end

    context "tag with context" do
      before(:each) do
        @tag = Tag.new('tag', [], [], { :foo => 'bar' })
      end

      it "should store context at parse time" do
        @tag.options[:foo].should == "bar"
      end
    end

  end
end