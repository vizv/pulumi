# frozen_string_literal: true

require 'optparse'

module Pulumi
  class Command
    class << self
      def run!
        pp Pulumi::Options.project
        pp Pulumi::Options.program
        pp Pulumi::Options.args
      end
    end
  end
end
