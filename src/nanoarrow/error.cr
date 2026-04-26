module Nanoarrow
  class Error < Exception
    getter code : Int32

    def initialize(@code : Int32, message : String)
      super("#{message} failed with errno-compatible code #{@code}")
    end

    def self.check(code : Int32, message : String) : Nil
      raise new(code, message) unless code == 0
    end
  end
end
