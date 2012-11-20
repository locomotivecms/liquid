require 'spec_helper'

module Liquid
  describe "Liquid Regular Expressions" do

    describe "QuotedFragment" do
      context "empty string" do
        it{ ''.scan(QuotedFragment).should == [] }
      end

      context %{quoted string: "arg 1"} do
        it{ %{"arg 1"}.scan(QuotedFragment).should == [%{"arg 1"}] }
      end

      context "arg1 arg2" do
        it{ subject.scan(QuotedFragment).should == ["arg1", "arg2"] }
      end

      context "<tr> </tr>" do
        it{ subject.scan(QuotedFragment).should == ['<tr>', '</tr>'] }
      end

      context "<tr></tr>" do
        it{ subject.scan(QuotedFragment).should == ['<tr></tr>'] }
      end

      context %{<style class="hello">' </style>} do
        it{ subject.scan(QuotedFragment).should == ['<style', 'class="hello">', '</style>'] }
      end

      context %{arg1 arg2 "arg 3"} do
        it{ subject.scan(QuotedFragment).should == ['arg1', 'arg2', '"arg 3"'] }
      end

      context "arg1 arg2 'arg 3'" do
        it{ subject.scan(QuotedFragment).should == ['arg1', 'arg2', "'arg 3'"] }
      end

      context %{arg1 arg2 "arg 3" arg4  } do
        it{ subject.scan(QuotedFragment).should == ['arg1', 'arg2', '"arg 3"', 'arg4'] }
      end
    end

    describe "VariableParser" do
      context "var" do
        it{ subject.scan(VariableParser).should == ['var'] }
      end

      context "var.method" do
        it{ subject.scan(VariableParser).should == ['var', 'method']}
      end

      context "var[method]" do
        it{ subject.scan(VariableParser).should == ['var', '[method]']}
      end

      context "var[method][0]" do
        it{ subject.scan(VariableParser).should == ['var', '[method]', '[0]'] }
      end

      context %{var["method"][0]} do
        it{ subject.scan(VariableParser).should == ['var', '["method"]', '[0]'] }
      end

      context "var['method'][0]" do
        it{ subject.scan(VariableParser).should == ['var', "['method']", '[0]'] }
      end

      context "var[method][0].method" do
        it{ subject.scan(VariableParser).should == ['var', '[method]', '[0]', 'method'] }
      end
    end

  end
end