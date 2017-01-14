#
# General module which holds all appropriate Watirsome API.
# Includers can use accessors and initializers API.
#
# @example Element Accessors
#   class Page
#     include Watirsome
#
#     element :body, tag_name: 'body'
#     div :container, class: 'container'
#   end
#
#   page = Page.new(@browser)
#   page.body_element  #=> @browser.element(tag_name: 'body')
#   page.container_div #=> @browser.div(class: 'container')
#
# @example Read Accessors
#   class Page
#     include Watirsome
#
#     div :container, class: 'container'
#     radio :sex_male, value: 'Male'
#   end
#
#   page = Page.new(@browser)
#   page.container #=> "Container"
#   page.sex_male_radio.set
#   page.sex_male #=> true
#
# @example Click Accessors
#   class Page
#     include Watirsome
#
#     a :open_google, text: 'Open Google'
#   end
#
#   page = Page.new(@browser)
#   page.open_google
#   @browser.title #=> "Google"
#
# @example Set Accessors
#   class Page
#     include Watirsome
#
#     text_field :name, placeholder: 'Enter your name'
#     select_list :country, name: 'Country'
#     checkbox :agree, name: 'I Agree'
#   end
#
#   page = Page.new(@browser)
#   page.name = "My name"
#   page.name #=> "My name"
#   page.country = "Russia"
#   page.country #=> "Russia"
#   page.agree = true
#   page.agree #=> true
#
# @example Locators
#   class Page
#     include Watirsome
#
#     div :visible, class: 'visible', visible: true
#     div :invisible, class: 'visible', visible: false
#     select_list :country, selected: 'USA'
#   end
#
#   page = Page.new(@browser)
#   page.visible_div.visible?   #=> true
#   page.invisible_div.visible? #=> false
#   page.country_select_list.selected?('USA') #=> true
#
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
  end # self

  def self.included(kls)
    kls.extend Watirsome::Accessors::ClassMethods
    kls.__send__ :include, Watirsome::Accessors::InstanceMethods
    kls.__send__ :include, Watirsome::Initializers
  end
end # Watirsome

require 'watir'
require 'watirsome/accessors'
require 'watirsome/initializers'
require 'watirsome/errors'
