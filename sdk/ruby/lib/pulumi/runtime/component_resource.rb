# frozen_string_literal: true

module Pulumi
  module Runtime
    # ComponentResource is a resource that aggregates one or more other child resources into a higher level abstraction.
    # The component resource itself is a resource, but does not require custom CRUD operations for provisioning.
    class ComponentResource < Resource
      OPTIONS_FIELDS = Resource::OPTIONS_FIELDS + %i[providers]
      Options = Struct.new(*OPTIONS_FIELDS, keyword_init: true)

      def initialize(type, name, args: {}, opts: Options.new, remote: false)
        super(type, name, false, props: remote || opts&.urn ? args : {}, opts: opts, remote: remote)
        @_remote = remote
        @_registered = remote || !!opts&.urn
      end

      def data()
        @_remote || opts
      end
    end
  end
end
