# frozen_string_literal: true

module Pulumi
  module Rpc
    class Engine < Base
      def initialize
        super('Engine', Pulumi::Options.engine)
      end

      def root_resource
        get_root_resource.urn
      end

      def root_resource=(resource)
        req = Pulumirpc::SetRootResourceRequest.new(urn: resource.urn)
      end
    end
  end
end
