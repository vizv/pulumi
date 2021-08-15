# frozen_string_literal: true

require 'singleton'

module Pulumi
  module Rpc
    class Base
      MODULE_PREFIX = 'Pulumirpc'

      # raises the gRPC Max Message size from `4194304` (4mb) to `419430400` (400mb)
      MAX_RPC_MESSAGE_SIZE = 1024 * 1024 * 400
      CHANNEL_ARGS = { 'grpc.max_receive_message_length': MAX_RPC_MESSAGE_SIZE }

      include Singleton

      protected def initialize(name, module_name, address)
        pb_module = "#{name}_services_pb"
        require pb_module

        stub_class = Object.const_get("::#{MODULE_PREFIX}::#{module_name}::Stub")
        @_proxy = stub_class.new(address, channel_args: CHANNEL_ARGS)
      end

      def respond_to_missing?(method, include_all = false)
        super || @_proxy.respond_to?(method, include_all)
      end

      def method_missing(method, *args, &block)
        return super unless respond_to?(method)

        @_proxy.send(method, *args, &block)
      end
    end
  end
end
