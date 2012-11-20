require 'spec_helper'

module Liquid
  describe BlankFileSystem do
    it "should error out when trying to ready any file" do
      expect {
        BlankFileSystem.new.read_template_file("dummy", nil)
      }.to raise_error(Liquid::FileSystemError)
    end
  end

  describe LocalFileSystem do
    describe "#full_path" do
      before(:each) do
        @file_system = LocalFileSystem.new("/some/path")
      end

      it "should translate partial paths to the full filesystem path" do
        @file_system.full_path('mypartial').should == "/some/path/_mypartial.liquid"
        @file_system.full_path('dir/mypartial').should == "/some/path/dir/_mypartial.liquid"
      end

      it "should raise errors if we try to go outside of the root" do
        expect {
          @file_system.full_path("../dir/mypartial")
        }.to raise_error(Liquid::FileSystemError)

        expect {
          @file_system.full_path("/dir/../../dir/mypartial")
        }.to raise_error(Liquid::FileSystemError)
      end

      it "should not allow absolute paths" do
        expect {
          @file_system.full_path("/etc/passwd")
        }.to raise_error(Liquid::FileSystemError)
      end

    end
  end
end