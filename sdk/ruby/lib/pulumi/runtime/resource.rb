# frozen_string_literal: true

module Pulumi
  module Runtime
    # Resource represents a class whose CRUD operations are implemented by a provider plugin.
    class Resource
      OPTIONS_FIELDS = %i[
        id
        parent
        depends_on
        protect
        ignore_changes
        replace_on_changes
        version
        aliases
        provider
        custom_timeouts
        transformations
        urn
      ]
      Options = Struct.new(*OPTIONS_FIELDS, keyword_init: true)

      class Error < StandardError
        attr_reader :parent, :hide_stack

        def initialize(message, parent: nil, hide_stack: false)
          @parent = parent
          @hide_stack = hide_stack

          super(message)
        end
      end

      def initialize(type, name, custom, props: {}, opts: Options.new, remote: false, dependency: false)
        if dependency
          @_protect = false
          @_provider = {}

          return
        end

        raise StandardError, "Resource parent is not a valid Resource: #{opts.parent}" if opts.parent && !opts.parent.is_a?(Resource)
        raise Error, 'Missing resource type argument', parent: opts.parent
        raise Error, 'Missing resource name argument (for URN creation)', parent: opts.parent

        # Before anything else:
        # if there are transformations registered, invoke them in order to transform the properties and options assigned to this resource.
        parent = opts.parent || Stack.resource
        transformations.push(*opts.transformations)
        transformations.push(*parent&.transformations)
        transformations.each do |transformation|
          result = transformation.call({ resource: self, type: type, name: name, props: props, opts: opts }) # TODO: change to types
          next if result.nil?

          # This is currently not allowed because the parent tree is needed to establish what transformation to apply in the first place, and to compute
          # inheritance of other resource options in the Resource constructor before transformations are run (so modifying it here would only even partially
          # take affect). It's theoretically possible this restriction could be lifted in the future, but for now just disallow re-parenting resources
          # in transformations to be safe.
          raise StandardError, 'Transformations cannot currently be used to change the `parent` of a resource.' if result.opts.parent != opts.parent

          props = result.props
          opts = result.opts
        end

        @_name = name

        # Make a shallow clone of opts to ensure we don't modify the value passed in.
        opts = opts.dup

        if opts.is_a?(ComponentResource::Options) && opts.provider && opts.providers
          raise Error, "Do not supply both 'provider' and 'providers' options to a ComponentResource.", parent: opts.parent
        end

        # Check the parent type if one exists and fill in any default options.
        @_providers = {}
        if opts.parent
          
        end
      end

      def transformations
        @transformations ||= []
      end
    end
  end
end
