module Watirsome
  module Accessors
    module ClassMethods

      #
      # Iterate thorugh Watir continer methods and define all necessary
      # class methods of element accessors.
      #
      Watirsome.watir_methods.each do |method|
        define_method method do |*args, &blk|
          name, args = parse_args(args)
          block = proc_from_args(args, &blk)
          define_element_accessor(name, method, args, &block)
          define_click_accessor(name, method, args, &block)  if Watirsome.clickable?(method)
          define_read_accessor(name, method, args, &block)   if Watirsome.readable?(method)
          define_set_accessor(name, method, args, &block)    if Watirsome.settable?(method)
          define_select_accessor(name, method, args, &block) if Watirsome.selectable?(method)
        end
      end

      private

      #
      # Returns name and locators.
      # @api private
      #
      def parse_args(args)
        return args.shift, args.shift
      end

      #
      # Returns block retreived from locators.
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
        define_method :"#{name}_#{method}" do |*opts|
          if block_given?
            instance_exec(*opts, &block)
          else
            grab_elements(method, watir_args, custom_args)
          end
        end
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
        define_method name do |*opts|
          if block_given?
            instance_exec(*opts, &block).click
          else
            grab_elements(method, watir_args, custom_args).click
          end
        end
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
          else
            element.text
          end
        end
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
        define_method :"#{name}=" do |*opts|
          element = if block_given?
                      instance_exec(&block)
                    else
                      grab_elements(method, watir_args, custom_args)
                    end
          if element.respond_to?(:set)
            element.set(*opts)
          else
            element.send_keys(*opts)
          end
        end
      end

      #
      # Defines accessor which selects option Watir element instance.
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
      def define_select_accessor(name, method, *args, &block)
        watir_args, custom_args = extract_custom_args(method, args)
        define_method :"#{name}=" do |*opts|
          if block_given?
            instance_exec(&block).select(*opts)
          else
            grab_elements(method, watir_args, custom_args).select(*opts)
          end
        end
      end

      #
      # Extracts custom arguments which Watirsome gracefully handles from
      # mixed array with Watir locators.
      #
      # @param [Symbol, String] method
      # @param [Array] args
      # @return Two arrays: Watir locators and custom locators
      # @api private
      #
      def extract_custom_args(method, *args)
        identifier = args.shift
        watir_args, custom_args = [], []
        identifier.each_with_index do |hashes, index|
          watir_arg, custom_arg = {}, {}
          if hashes && !hashes.is_a?(Proc)
            hashes.each do |k, v|
              if Watir.element_class_for(method).instance_methods.include? :"#{k}?"
                custom_arg[k] = identifier[index][k]
              else
                watir_arg[k] = v
              end
            end
          end
          watir_args  << watir_arg  unless watir_arg.empty?
          custom_args << custom_arg unless custom_arg.empty?
        end

        return watir_args, custom_args
      end

    end # ClassMethods


    module InstanceMethods

      private

      #
      # Calls Watir browser instance to find element.
      #
      # @param [Symbol] method Watir method
      # @param [Array] watir_args Watir locators
      # @param [Array] custom_args Custom locators
      # @api private
      #
      def grab_elements(method, watir_args, custom_args)
        if custom_args.empty?
          @browser.send(method, *watir_args)
        else
          plural = Watirsome.plural?(method)
          method = Watirsome.pluralize(method) unless plural
          elements = @browser.send(method, *watir_args)
          custom_args.first.each do |k, v|
            elements.to_a.select! do |e|
              if e.public_method(:"#{k}?").arity == 0
                e.send(:"#{k}?") == v
              else
                e.send(:"#{k}?", v)
              end
            end
          end
          plural ? elements : elements.first
        end
      end

    end # InstanceMethods
  end # Accessors
end # Watirsome
