module Watirsome
  module Regions
    #
    # Defines region accessor.
    #
    # @param [Symbol] region_name
    # @param [Hash|Proc] in, optional, alias: within
    # @param [Class] class, optional, alias: region_class
    # @param [Block] block
    #
    def has_one(region_name, **opts, &block)
      within = opts[:in] || opts[:within]
      region_class = opts[:class] || opts[:region_class]
      define_region_accessor(region_name, within: within, region_class: region_class, &block)
    end

    #
    # Defines multiple regions accessor.
    #
    # @param [Symbol] region_name
    # @param [Hash|Proc] in, optional, alias: within
    # @param [Hash] each, required
    # @param [Class] class, optional, alias: region_class
    # @param [Class] through, optional, alias collection_class
    # @param [Block] block, optional
    #
    def has_many(region_name, **opts, &block)
      region_class = opts[:class] || opts[:region_class]
      collection_class = opts[:through] || opts[:collection_class]
      each = opts[:each] || raise(ArgumentError, '"has_many" method requires "each" param')
      within = opts[:in] || opts[:within]
      define_region_accessor(region_name, within: within, each: each, region_class: region_class, collection_class: collection_class, &block)
      define_finder_method(region_name)
    end

    private

    # FIXME: the generated method is far too complex, and deserves a proper refactoring
    # rubocop:disable all
    def define_region_accessor(region_name, within: nil, each: nil, collection_class: nil, region_class: nil, &block)
      define_method(region_name) do
        # FIXME: ['MakeItSizeOne'] is required when current class is anonymous (inline region)
        class_path = self.class.name ? self.class.name.split('::') : ['MakeItSizeOne']
        namespace = if class_path.size > 1
                      class_path.pop
                      Object.const_get(class_path.join('::'))
                    elsif class_path.size == 1
                      self.class
                    else
                      raise "Cannot understand namespace from #{class_path}"
                    end

        # This copy is required since `region_class` is declared outside of this defined function,
        # and the function could change it
        region_single_class = region_class

        unless region_single_class
          if block_given?
            region_single_class = Class.new
            region_single_class.class_eval { include(Watirsome) }
            region_single_class.class_eval(&block)
          else
            singular_klass = region_name.to_s.split('_').map(&:capitalize).join
            if each
              collection_class_name = "#{singular_klass}Region"
              singular_klass = singular_klass.sub(/s\z/, '')
            end
            singular_klass << 'Region'
            region_single_class = namespace.const_get(singular_klass)
          end
        end

        scope = case within
                when Proc
                  instance_exec(&within)
                when Hash
                  region_element.element(within)
                else
                  region_element
                end

        if each
          elements = (scope.exists? ? scope.elements(each) : [])

          if collection_class_name && namespace.const_defined?(collection_class_name)
            region_collection_class = namespace.const_get(collection_class_name)
          elsif collection_class
            region_collection_class = collection_class
          else
            return elements.map { |element| region_single_class.new(@browser, element, self) }
          end

          region_collection_class.class_eval do
            include Enumerable

            attr_reader :region_collection

            define_method(:initialize) do |browser, region_element, region_elements|
              super(browser, region_element, self)
              @region_collection = if region_elements.all? { |element| element.is_a?(Watir::Element) }
                                     region_elements.map { |element| region_single_class.new(browser, element, self) }
                                   else
                                     region_elements
                                   end
            end

            def each(&block)
              region_collection.each(&block)
            end
          end

          region_collection_class.new(@browser, scope, elements)
        else
          region_single_class.new(@browser, scope, self)
        end
      end
    end
    # rubocop:enable all

    def define_finder_method(region_name)
      finder_method_name = region_name.to_s.sub(/s\z/, '')
      define_method(finder_method_name) do |**opts|
        __send__(region_name).find do |entity|
          opts.all? do |key, value|
            entity.__send__(key) == value
          end
        end || raise("No #{finder_method_name} matching: #{opts}.")
      end
    end
  end
end
