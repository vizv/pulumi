# frozen_string_literal: true

Signal.trap('INT') do
  puts
  exit 1
end

begin
  Pulumi::Command.run!
rescue OptionParser::MissingArgument => e
  puts e
end
