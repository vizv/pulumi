# frozen_string_literal: true

require 'json'
require 'set'

module Pulumi
  module Runtime
    module Env
      ENV_CONFIG = 'PULUMI_CONFIG'
      ENV_SECRET_KEYS = 'PULUMI_CONFIG_SECRET_KEYS'

      class << self
        def config_hash
          @config_hash ||= JSON.parse(ENV.fetch(ENV_CONFIG, '{}')).freeze
        end

        def secret_keys
          # TODO: should to_a?
          @secret_keys ||= Set.new(JSON.parse(ENV.fetch(ENV_SECRET_KEYS, '[]'))).freeze
        end
      end
    end
  end
end
