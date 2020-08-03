# frozen_string_literal: true

module Watirsome
  class << self
    #
    # Returns array of readable elements.
    # @return [Array<Symbol>]
    #
    def readable
      @readable ||= %i[div span p h1 h2 h3 h4 h5 h6 select_list text_field textarea checkbox radio]
    end

    #
    # Returns array of clickable elements.
    # @return [Array<Symbol>]
    #
    def clickable
      @clickable ||= %i[a link button]
    end

    #
    # Returns array of settable elements.
    # @return [Array<Symbol>]
    #
    def settable
      @settable ||= %i[text_field file_field textarea checkbox select_list]
    end

    #
    # Returns true if tag can have click accessor.
    #
    # @example
    #   Watirsome.clickable?(:button) #=> true
    #   Watirsome.clickable?(:div)    #=> false
    #
    # @param [Symbol, String] tag
    # @return [Boolean]
    #
    def clickable?(tag)
      clickable.include? tag.to_sym
    end

    #
    # Returns true if tag can have set accessor.
    #
    # @example
    #   Watirsome.settable?(:text_field) #=> true
    #   Watirsome.settable?(:button)     #=> false
    #
    # @param [Symbol, String] tag
    # @return [Boolean]
    #
    def settable?(tag)
      settable.include? tag.to_sym
    end

    #
    # Returns true if tag can have text accessor.
    #
    # @example
    #   Watirsome.readable?(:div)  #=> true
    #   Watirsome.readable?(:body) #=> false
    #
    # @param [Symbol, String] tag
    # @return [Boolean]
    #
    def readable?(tag)
      readable.include? tag.to_sym
    end

    #
    # Returns array of Watir element methods.
    # @return [Array<Sybmol>]
    #
    def watir_methods
      unless @watir_methods
        @watir_methods = Watir::Container.instance_methods
        @watir_methods.delete(:extract_selector)
      end

      @watir_methods
    end

    #
    # Return true if method can be proxied to Watir, false otherwise.
    #
    # @example
    #   Watirsome.watirsome?(:div)  #=> true
    #   Watirsome.watirsome?(:to_a) #=> false
    #
    # @param [Symbol] method
    # @return [Boolean]
    #
    def watirsome?(method)
      Watirsome.watir_methods.include? method.to_sym
    end

    #
    # Returns true if method is element accessor in plural form.
    #
    # @example
    #   Watirsome.plural?(:divs) #=> true
    #   Watirsome.plural?(:div)  #=> false
    #
    # @param [Symbol, String] method
    # @return [Boolean]
    # @api private
    #
    def plural?(method)
      str = method.to_s
      plr = str.to_sym
      sgl = str.sub(/e?s$/, '').to_sym

      !str.match(/s$/).nil? &&
        Watirsome.watir_methods.include?(plr) &&
        Watirsome.watir_methods.include?(sgl)
    end

    #
    # Pluralizes element.
    #
    # @example
    #   Watirsome.pluralize(:div)       #=> :divs
    #   Watirsome.pluralize(:checkbox)  #=> :checkboxes
    #
    # @param [Symbol, String] method
    # @return [Symbol]
    # @api private
    #
    def pluralize(method)
      str = method.to_s
      # first try to pluralize with "s"
      if Watirsome.watir_methods.include?(:"#{str}s")
        :"#{str}s"
      # now try to pluralize with "es"
      elsif Watirsome.watir_methods.include?(:"#{str}es")
        :"#{str}es"
      else
        # looks like we can't pluralize it
        raise Errors::CannotPluralizeError, "Can't find plural form for #{str}!"
      end
    end
  end

  def self.included(kls)
    kls.extend Watirsome::Accessors::ClassMethods
    kls.extend Watirsome::Regions
    kls.__send__ :include, Watirsome::Accessors::InstanceMethods
    kls.__send__ :include, Watirsome::Initializers
  end
end

require 'watir'
require 'watirsome/accessors'
require 'watirsome/errors'
require 'watirsome/initializers'
require 'watirsome/regions'
