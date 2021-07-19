require "string_scanner"

module LuckySupervisor
  class ProcfileParser
    record Entry, process_type : String, command : String

    def initialize(@input : String)
    end

    def parse
      s = StringScanner.new(@input)
      line = 0
      entries = [] of Entry

      while !s.eos?
        line += 1

        s.skip(/\s*/)
        process_type = s.scan(/[[:alnum:]]+/)
        s.skip(/\s*/)

        if s.peek(1) != ":"
          raise ParseException.new("Unexpected char `#{@input[s.offset]}'", line, s.offset + 1)
        end

        s.offset += 1

        s.skip(/\s*/)
        command = s.scan_until(/[^\n]+/)
        s.skip(/\s*/)

        if command.nil?
          raise ParseException.new("command missing", line, s.offset + 1)
        end

        entries << Entry.new(process_type.not_nil!, command)
      end

      entries
    end
  end
end
