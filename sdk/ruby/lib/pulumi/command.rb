# frozen_string_literal: true

require 'thor'

module Pulumi
  class Command < Thor
    default_task :exec

    desc 'exec', 'Execute a Pulumi Ruby program'
    method_options project: :string, stack: :string, parallel: :numeric,
                   dry_run: :boolean, pwd: :string, monitor: :string,
                   engine: :string, tracing: :string
    def exec
      pp options
      pp VERSION
    end
  end
end
