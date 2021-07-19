require "./spec_helper"

describe LuckySupervisor::ProcfileParser do
  it "parses a single entry" do
    parser = LuckySupervisor::ProcfileParser.new(<<-PROCFILE)
      web: bundle exec rails server -p $PORT
      PROCFILE

    entries = parser.parse

    entries.size.should eq(1)
    entries[0].process_type.should eq("web")
    entries[0].command.should eq("bundle exec rails server -p $PORT")
  end

  it "parses multiple entries" do
    parser = LuckySupervisor::ProcfileParser.new(<<-PROCFILE)
      release:       ./release-tasks.sh
      worker:        env QUEUE=* bundle exec rake resque:work
      urgentworker:  env QUEUE=urgent bundle exec rake resque:work
      PROCFILE

    entries = parser.parse

    entries.size.should eq(3)
    entries[0].process_type.should eq("release")
    entries[0].command.should eq("./release-tasks.sh")
    entries[1].process_type.should eq("worker")
    entries[1].command.should eq("env QUEUE=* bundle exec rake resque:work")
    entries[2].process_type.should eq("urgentworker")
    entries[2].command.should eq("env QUEUE=urgent bundle exec rake resque:work")
  end

  it "parses unconventionally formatted entries" do
    parser = LuckySupervisor::ProcfileParser.new(<<-PROCFILE)

         
      release: ./release-tasks.sh

      worker  :	env QUEUE=* bundle exec rake resque:work


      urgentworker:env QUEUE=urgent bundle exec rake resque:work


      PROCFILE

    entries = parser.parse

    entries.size.should eq(3)
    entries[0].process_type.should eq("release")
    entries[0].command.should eq("./release-tasks.sh")
    entries[1].process_type.should eq("worker")
    entries[1].command.should eq("env QUEUE=* bundle exec rake resque:work")
    entries[2].process_type.should eq("urgentworker")
    entries[2].command.should eq("env QUEUE=urgent bundle exec rake resque:work")
  end

  it "parses alphanumeric process types only" do
    parser = LuckySupervisor::ProcfileParser.new(<<-PROCFILE)
      web_2: bundle exec rails server -p $PORT
      PROCFILE
    message = <<-MSG
      Unexpected char `_' at line 1, column 4
      MSG

    e = expect_raises(LuckySupervisor::ParseException, message) { parser.parse }
    e.line_number.should eq(1)
    e.column_number.should eq(4)
  end

  it "parses non-empty commands only" do
    parser = LuckySupervisor::ProcfileParser.new(<<-PROCFILE)
      web:
      PROCFILE
    message = <<-MSG
      command missing at line 1, column 5
      MSG

    e = expect_raises(LuckySupervisor::ParseException, message) { parser.parse }
    e.line_number.should eq(1)
    e.column_number.should eq(5)
  end
end
