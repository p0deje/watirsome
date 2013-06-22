module Watirsome
  class << self

    # @attr [Array<Symbol>] readable
    attr_accessor :readable

    # @attr [Array<Symbol>] clickable
    attr_accessor :clickable

    # @attr [Array<Symbol>] settable
    attr_accessor :settable

    # @attr [Array<Symbol>] selectable
    attr_accessor :selectable

    #
    # Returns array of readable elements.
    # @return [Array<Symbol>]
    #
    def readable
      @readable ||= [:div, :span, :p, :h1, :h2, :h3, :h4, :h5, :h6, :select_list, :text_field, :textarea]
    end

    #
    # Returns array of clickable elements.
    # @return [Array<Symbol>]
    #
    def clickable
      @clickable ||= [:a, :link, :button]
    end

    #
    # Returns array of settable elements.
    # @return [Array<Symbol>]
    #
    def settable
      @settable ||= [:text_field, :file_field, :textarea, :checkbox]
    end

    #
    # Returns array of selectable elements.
    # @return [Array<Symbol>]
    #
    def selectable
      @selectable ||= [:select_list]
    end

    #
    # Returns true if tag can have click accessor.
    #
    # @param [Symbol, String] method
    # @return [Boolean]
    #
    def clickable?(tag)
      clickable.include? tag.to_sym
    end

    #
    # Returns true if tag can have set accessor.
    #
    # @param [Symbol, String] method
    # @return [Boolean]
    #
    def settable?(tag)
      settable.include? tag.to_sym
    end

    #
    # Returns true if tag can have select accessor.
    #
    # @param [Symbol, String] method
    # @return [Boolean]
    #
    def selectable?(tag)
      selectable.include? tag.to_sym
    end

    #
    # Returns true if tag can have text accessor.
    #
    # @param [Symbol, String] method
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
    #   Watirsome.plural? :div   #=> false
    #   Watirsome.plural? :divs  #=> true
    #
    # @param [Symbol, String] method
    # @return [Boolean]
    # @api private
    #
    def plural?(method)
      str = method.to_s
      plr = str.to_sym
      sgl = str.sub(/e?s$/, '').to_sym

      /s$/ === str && Watirsome.watir_methods.include?(plr) && Watirsome.watir_methods.include?(sgl)
    end

    #
    # Pluralizes element.
    #
    # @example
    #   Watirsome.pluralize :div       #=> :divs
    #   Watirsome.pluralize :checkbox  #=> :checkboxes
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

  end # self


  def self.included(kls)
    kls.extend         Watirsome::Accessors::ClassMethods
    kls.send :include, Watirsome::Accessors::InstanceMethods
    kls.send :include, Watirsome::Initializers
  end

end # Watirsome


require 'watir-webdriver'
require 'watirsome/accessors'
require 'watirsome/initializers'
require 'watirsome/errors'
