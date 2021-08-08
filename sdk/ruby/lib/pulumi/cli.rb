# frozen_string_literal: true

Signal.trap('INT') do
  puts
  exit 1
end

begin
  pp Pulumi::Options.project
  pp Pulumi::Options.program
  pp Pulumi::Options.args
rescue OptionParser::MissingArgument => e
  puts e
rescue NoMethodError => e
  puts "missing option: #{e.name}"
end
