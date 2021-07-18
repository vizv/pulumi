# frozen_string_literal: true

require 'pulumi/ruby_version_check'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/pulumi/cli.rb")
loader.ignore("#{__dir__}/pulumi/ruby_version_check.rb")
loader.setup

module Pulumi
  class Error < StandardError; end
end
