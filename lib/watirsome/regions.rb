module Watirsome
  module Regions
    #
    # Defines region accessor.
    #
    # @param [Symbol] region_name
    #
    def has_one(region_name)
      define_region_accessor(region_name)
    end

    #
    # Defines multiple regions accessor.
    #
    # @param [Symbol] region_name
    # @param [Hash] within
    # @param [Hash] each
    #
    def has_many(region_name, within: nil, each:)
      define_region_accessor(region_name, within: within, each: each)
      define_finder_method(region_name)
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def define_region_accessor(region_name, within: nil, each: nil)
      define_method(region_name) do
        class_path = self.class.name.split('::')
        namespace = if class_path.size > 1
                      class_path.pop
                      Object.const_get(class_path.join('::'))
                    elsif class_path.size == 1
                      self.class
                    else
                      raise "Cannot understand namespace from #{class_path}"
                    end

        singular_klass = region_name.to_s.split('_').map(&:capitalize).join
        if each
          collection_klass = "#{singular_klass}Region"
          singular_klass = singular_klass.sub(/s\z/, '')
        end
        singular_klass << 'Region'

        region_class = namespace.const_get(singular_klass)
        region_class.class_eval do
          attr_reader :region_element
          attr_accessor :parent

          def initialize(browser, region_element, parent)
            super(browser)
            @region_element = region_element
            @parent = parent
          end
        end

        scope = case within
                when Proc
                  instance_exec(&within)
                when Hash
                  @browser.element(within)
                else
                  @browser
                end

        if each
          collection = if scope.exists?
                         scope.elements(each).map do |element|
                           region_class.new(@browser, element, self)
                         end
                       else
                         []
                       end

          return collection unless namespace.const_defined?(collection_klass)

          region_collection_class = namespace.const_get(collection_klass)
          region_collection_class.class_eval do
            include Enumerable

            attr_reader :region_element
            attr_reader :region_collection

            def initialize(browser, region_element, region_collection)
              super(browser)
              @region_element = region_element
              @region_collection = region_collection
            end

            def each(&block)
              region_collection.each(&block)
            end
          end

          region_collection_instance = region_collection_class.new(@browser, scope, collection)
          collection.each do |region|
            region.parent = region_collection_instance
          end

          region_collection_instance
        else
          region_class.new(@browser, @browser, self)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

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
