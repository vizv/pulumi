# frozen_string_literal: true

require 'optparse'

module Pulumi
  module Command
    class << self
      def run!
        pwd = Pulumi::Options.pwd rescue Dir.pwd
        Dir.chdir(pwd)

        pp Pulumi::Runtime::Env.config_hash
        pp Pulumi::Runtime::Env.secret_keys

        pp Pulumi::Options.project
        pp pwd
        # pp Pulumi::Options.project
        # pp Pulumi::Options.program
        # pp Pulumi::Options.args
      end
    end
  end
end
