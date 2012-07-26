module RSpec
  module MultilineString
    #
    # used to format multiline strings (prefix lines with |)
    #
    # example:
    #
    # multiline_template <<-END
    # |  hello
    # |  |
    # |  |
    # END
    #
    # this parses to:
    # "  hello\n  \n  \n
    #
    def multiline_string(string, pipechar = '|')
      arr = string.split("\n")             # Split into lines
      arr.map! {|x| x.sub(/^\s*\| /, "")}  # Remove leading characters
      arr.map! {|x| x.sub(/\|$/,"")}      # Remove ending characters
      arr.join("\n")                       # Rejoin into a single line
    end
  end
end

RSpec.configure do |c|
  c.include RSpec::MultilineString
end