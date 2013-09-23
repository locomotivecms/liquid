module Liquid
  class Error < ::StandardError

    attr_accessor :line

    def initialize(message = nil, line = nil)
      @line = line
      super(message)
    end

  end

  class ArgumentError < Error; end
  class ContextError < Error; end
  class FilterNotFound < Error; end
  class FileSystemError < Error; end
  class StandardError < Error; end
  class SyntaxError < Error; end
  class StackLevelError < Error; end
  class MemoryError < Error; end
end
