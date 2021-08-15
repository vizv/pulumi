# frozen_string_literal: true

module Pulumi
  module Rpc
    class Monitor < Base
      def initialize
        super('resource', 'ResourceMonitor', Pulumi::Options.monitor)
      end
    end
  end
end
