require 'spec_helper'

module Liquid
  describe Variable do
    it "#name" do
      var = Variable.new('hello')
      var.name.should == 'hello'
    end

    it "should parse and store filters" do
      var = Variable.new('hello | textileze')
      var.name.should == 'hello'
      var.filters.should == [['textileze',[]]]

      var = Variable.new('hello | textileze | paragraph')
      var.name.should == 'hello'
      var.filters.should == [['textileze',[]], ['paragraph',[]]]

      var = Variable.new(%! hello | strftime: '%Y'!)
      var.name.should == 'hello'
      var.filters.should == [['strftime',["'%Y'"]]]

      var = Variable.new(%! 'typo' | link_to: 'Typo', true !)
      var.name.should == %!'typo'!
      var.filters.should == [['link_to',["'Typo'", "true"]]]

      var = Variable.new(%! 'typo' | link_to: 'Typo', false !)
      var.name.should == %!'typo'!
      var.filters.should == [['link_to',["'Typo'", "false"]]]

      var = Variable.new(%! 'foo' | repeat: 3 !)
      var.name.should == %!'foo'!
      var.filters.should == [['repeat',["3"]]]

      var = Variable.new(%! 'foo' | repeat: 3, 3 !)
      var.name.should == %!'foo'!
      var.filters.should == [['repeat',["3","3"]]]

      var = Variable.new(%! 'foo' | repeat: 3, 3, 3 !)
      var.name.should == %!'foo'!
      var.filters.should == [['repeat',["3","3","3"]]]

      var = Variable.new(%! hello | strftime: '%Y, okay?'!)
      var.name.should == 'hello'
      var.filters.should == [['strftime',["'%Y, okay?'"]]]

      var = Variable.new(%! hello | things: "%Y, okay?", 'the other one'!)
      var.name.should == 'hello'
      var.filters.should == [['things',["\"%Y, okay?\"","'the other one'"]]]
    end

    it "should store filters with parameters" do
      var = Variable.new(%! '2006-06-06' | date: "%m/%d/%Y"!)
      var.name.should == "'2006-06-06'"
      var.filters.should == [['date',["\"%m/%d/%Y\""]]]
    end

    it "should allow filters without whitespace" do
      var = Variable.new('hello | textileze | paragraph')
      var.name.should == 'hello'
      var.filters.should == [['textileze',[]], ['paragraph',[]]]

      var = Variable.new('hello|textileze|paragraph')
      var.name.should == 'hello'
      var.filters.should == [['textileze',[]], ['paragraph',[]]]
    end

    it "should allow special characters" do
      var = Variable.new("http://disney.com/logo.gif | image: 'med' ")
      var.name.should == 'http://disney.com/logo.gif'
      var.filters.should == [['image',["'med'"]]]
    end

    it "should allow double quoted strings" do
      var = Variable.new(%| "hello" |)
      var.name.should == '"hello"'
    end

    it "should allow single quoted strings" do
      var = Variable.new(%| 'hello' |)
      var.name.should == "'hello'"
    end

    it "should allow integers" do
      var = Variable.new(%| 1000 |)
      var.name.should == "1000"
    end

    it "should allow floats" do
      var = Variable.new(%| 1000.01 |)
      var.name.should == "1000.01"
    end

    it "should allow strings with special characters" do
      var = Variable.new(%| 'hello! $!@.;"ddasd" ' |)
      var.name.should == %|'hello! $!@.;"ddasd" '|
    end

    it "should allow strings with dots" do
      var = Variable.new(%| test.test |)
      var.name.should == 'test.test'
    end
  end
end