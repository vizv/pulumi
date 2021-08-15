# frozen_string_literal: true

require 'pulumi/ruby_version_check'

proto_lib = "#{__dir__}/pulumi/proto"
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/pulumi/cli.rb")
loader.ignore("#{__dir__}/pulumi/ruby_version_check.rb")
loader.ignore("#{__dir__}/pulumi/proto/*.rb")
loader.setup

module Pulumi
  class Error < StandardError; end
end
