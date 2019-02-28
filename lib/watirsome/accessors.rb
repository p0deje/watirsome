module Watirsome
  module Accessors
    SKIP_CUSTOM_SELECTORS = %i[visible].freeze

    module ClassMethods
      #
      # Iterate through Watir continer methods and define all necessary
      # class methods of element accessors.
      #
      Watirsome.watir_methods.each do |method|
        define_method method do |*args, &blk|
          name, args = parse_args(args)
          block = proc_from_args(args, &blk)
          define_element_accessor(name, method, args, &block)
          define_click_accessor(name, method, args, &block) if Watirsome.clickable?(method)
          define_read_accessor(name, method, args, &block)  if Watirsome.readable?(method)
          define_set_accessor(name, method, args, &block)   if Watirsome.settable?(method)
        end
      end

      private

      #
      # Returns name and locators.
      # @api private
      #
      def parse_args(args)
        [args.shift, args.shift]
      end

      #
      # Returns block retrieved from locators.
      # @api private
      #
      def proc_from_args(*args, &blk)
        if block_given?
          blk
        else
          block = args.shift
          block.is_a?(Proc) && args.empty? ? block : nil
        end
      end

      #
      # Defines accessor which returns Watir element instance.
      # Method name is element name + tag.
      #
      # @param [Symbol] name Element name
      # @param [Symbol] method Watir method
      # @param [Array] args Splat of locators
      # @param [Proc] block Block as element retriever
      # @api private
      #
      def define_element_accessor(name, method, *args, &block)
        watir_args, custom_args = extract_custom_args(method, args)
        include(Module.new do
          define_method "#{name}_#{method}" do |*opts|
            if block_given?
              instance_exec(*opts, &block)
            else
              grab_elements(method, watir_args, custom_args)
            end
          end
        end)
      end

      #
      # Defines accessor which clicks Watir element instance.
      # Method name is element name.
      #
      # @param [Symbol] name Element name
      # @param [Symbol] method Watir method
      # @param [Array] args Splat of locators
      # @param [Proc] block Block as element retriever
      # @api private
      #
      def define_click_accessor(name, method, *args, &block)
        watir_args, custom_args = extract_custom_args(method, args)
        include(Module.new do
          define_method name do |*opts|
            if block_given?
              instance_exec(*opts, &block).click
            else
              grab_elements(method, watir_args, custom_args).click
            end
          end
        end)
      end

      #
      # Defines accessor which returns text of Watir element instance.
      # Method name is element name.
      #
      # For textfield and textarea, value is returned.
      # For select list, selected option text is returned.
      # For other elements, text is returned.
      #
      # @param [Symbol] name Element name
      # @param [Symbol] method Watir method
      # @param [Array] args Splat of locators
      # @param [Proc] block Block as element retriever
      # @api private
      #
      def define_read_accessor(name, method, *args, &block)
        watir_args, custom_args = extract_custom_args(method, args)
        include(Module.new do
          define_method name do |*opts|
            element = if block_given?
                        instance_exec(*opts, &block)
                      else
                        grab_elements(method, watir_args, custom_args)
                      end
            case method
            when :text_field, :textarea
              element.value
            when :select_list
              element.options.detect(&:selected?).text
            when :checkbox, :radio
              element.set?
            else
              element.text
            end
          end
        end)
      end

      #
      # Defines accessor which sets value of Watir element instance.
      # Method name is element name + "=".
      #
      # Note that custom block arguments are not used here.
      #
      # @param [Symbol] name Element name
      # @param [Symbol] method Watir method
      # @param [Array] args Splat of locators
      # @param [Proc] block Block as element retriever
      # @api private
      #
      def define_set_accessor(name, method, *args, &block)
        watir_args, custom_args = extract_custom_args(method, args)
        include(Module.new do
          define_method "#{name}=" do |*opts|
            element = if block_given?
                        instance_exec(&block)
                      else
                        grab_elements(method, watir_args, custom_args)
                      end
            if element.is_a?(Watir::Select)
              element.select(*opts)
            elsif element.respond_to?(:set)
              element.set(*opts)
            else
              element.send_keys(*opts)
            end
          end
        end)
      end

      #
      # Extracts custom arguments which Watirsome gracefully handles from
      # mixed array with Watir locators.
      #
      # @param [Symbol, String] method
      # @param [Array] args
      # @return [Array<Hash>] two hashes: watir locators and custom locators
      # @api private
      #
      def extract_custom_args(method, *args)
        identifier = args.shift
        watir_args = {}
        custom_args = {}

        identifier.each_with_index do |hashes, index|
          next if hashes.nil? || hashes.is_a?(Proc)

          hashes.each do |k, v|
            element_methods = Watir.element_class_for(method).instance_methods
            if element_methods.include?(:"#{k}?") && !SKIP_CUSTOM_SELECTORS.include?(k)
              custom_args[k] = identifier[index][k]
            else
              watir_args[k] = v
            end
          end
        end

        [watir_args, custom_args]
      end
    end

    module InstanceMethods
      private

      #
      # Finds element relative to current `region_element`
      # For top-level components it's Watir browser reference
      #
      # @param [Symbol] method Watir method
      # @param [Hash] watir_args Watir locators
      # @param [Hash] custom_args Custom locators
      # @api private
      #
      def grab_elements(method, watir_args, custom_args)
        if custom_args.empty?
          region_element.__send__(method, watir_args)
        else
          plural = Watirsome.plural?(method)
          method = Watirsome.pluralize(method) unless plural
          elements = region_element.__send__(method, watir_args)
          custom_args.each do |k, v|
            elements.to_a.select! do |e|
              if e.public_method(:"#{k}?").arity.zero?
                e.__send__(:"#{k}?") == v
              else
                e.__send__(:"#{k}?", v)
              end
            end
          end
          plural ? elements : elements.first
        end
      end
    end
  end
end
