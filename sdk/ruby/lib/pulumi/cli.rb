# frozen_string_literal: true

Signal.trap('INT') do
  puts
  exit 1
end

Pulumi::Command.start(ARGV)
