# frozen_string_literal: true

require 'optparse'

module Pulumi
  class Options
    class << self
      BANNER = "Usage: #{$PROGRAM_NAME} [OPTIONS] PROGRAM ARGS"

      private def set_attr(name, value)
        define_singleton_method(name) { value }
      end

      private def option(name, help, optional: false)
        @parser ||= ::OptionParser.new(BANNER)

        opts = "--#{name}"
        opts += "=#{name.upcase}"
        @parser.on(opts, help) do |value|
          set_attr(name, value)
        end
      end

      private def parse!
        return if @parsed

        @parser.parse!

        program = ARGV.shift
        set_attr('program', program) unless program.nil?
        set_attr('args', ARGV.dup)

        ARGV.clear

        @parsed = true
      end

      def respond_to_missing?(method, include_all = false)
        super
      end

      def method_missing(method, *args, &block)
        parse!

        return super unless respond_to?(method)

        send(method)
      rescue NoMethodError => e
        raise OptionParser::MissingArgument, e.name
      end
    end

    option :monitor, 'An RPC address for the resource monitor to connect to'
    option :engine, 'An RPC address for the engine to connect to'
    option :project, 'Set the project name'
    option :stack, 'Set the stack name'
    option :pwd, 'Change the working directory before running the program'
    option :dry_run, 'Simulate resource changes, but without making them'
    option :parallel, 'Run P resource operations in parallel (default=none)'
    option :tracing, 'A Zipkin-compatible endpoint to send tracing data to'
  end
end
