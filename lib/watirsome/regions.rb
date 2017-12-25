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
    # @param [Hash] each
    #
    def has_many(region_name, each:)
      define_region_accessor(region_name, each: each)
      define_finder_method(region_name)
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
    def define_region_accessor(region_name, each: nil)
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
        klass = region_name.to_s.split('_').map(&:capitalize).join
        klass.sub!(/s\z/, '') if each
        klass << 'Region'

        if each
          @browser.elements(each).map do |element|
            region = namespace.const_get(klass).new(@browser)
            region.instance_variable_set(:@region_element, element)
            region.instance_exec do
              def region_element
                @region_element
              end
            end

            region
          end
        else
          namespace.const_get(klass).new(@browser)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength

    def define_finder_method(region_name)
      finder_method_name = region_name.to_s.sub(/s\z/, '')
      define_method(finder_method_name) do |**opts|
        __send__(region_name).find do |entity|
          opts.all? do |key, value|
            entity.__send__(key) == value
          end
        end
      end
    end
  end
end
