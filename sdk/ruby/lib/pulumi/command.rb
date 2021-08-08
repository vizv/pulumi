# frozen_string_literal: true

require 'optparse'

module Pulumi
  module Command
    class << self
      def run!
        pp Pulumi::Runtime::Env.config_hash
        pp Pulumi::Runtime::Env.secret_keys
        # pp Pulumi::Options.project
        # pp Pulumi::Options.program
        # pp Pulumi::Options.args
      end
    end
  end
end
