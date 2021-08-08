# frozen_string_literal: true

require 'optparse'

module Pulumi
  class Command
    class << self
      def options
        Options.options
        # return @options unless @options.nil?

        # @options = {}

        # OptionParser.new do |opts|
        #   opts.banner = "Usage: #{$PROGRAM_NAME} [OPTIONS] PROGRAM ARGS"
        #   opts.on('--project=PROJECT', 'Set the project name') { |v| @options[:project] = v }
        # end.parse!

        # @options
      end
    end
  end
end
