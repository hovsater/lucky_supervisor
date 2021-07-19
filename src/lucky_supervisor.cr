module LuckySupervisor
  VERSION = "0.1.0"

  class Error < Exception
  end

  class ParseException < Error
    getter line_number : Int32
    getter column_number : Int32

    def initialize(message, @line_number, @column_number, cause = nil)
      super("#{message} at line #{@line_number}, column #{@column_number}", cause)
    end
  end
end

require "./lucky_supervisor/*"
