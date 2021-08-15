# frozen_string_literal: true

module Pulumi
  module Runtime
    # Stack is the root resource for a Pulumi stack. Before invoking the `init` callback, it registers itself as the root resource with the Pulumi engine.
    class Stack < ComponentResource
      TYPE_NAME = 'pulumi:pulumi:Stack'

      class << self
        attr_reader :resource

        def run(&block)
          Stack.new(block).outputs
        end
      end

      private def initialize(init)
        super(TYPE_NAME, "#{Pulumi::Options.project}-#{Pulumi::Options.stack}", args: { init: init })
        # parent = Rpc::Engine.instance.root_resource
        # raise StandardError, 'Only one root Pulumi Stack may be active at once' unless parent.nil?
        # Rpc::Engine.instance.root_resource = self

        # super(parent)
      end

      def output
        # FIXME: ???
        data
      end
    end
  end
end
