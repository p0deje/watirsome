#
# Watirsome is a pure dynamic Watir-based page object DSL.
# Includers can use accessors, initializers and regions APIs.
#
# Accessors DSL allows to isolate elements from your methods.
# All accessors are just proxied to Watir, thus you free to use all its power in
# your page objects:
#
#   * any method defined in Watir::Container is accessible;
#   * you can use any kind of locators you use with Watir.
#
# For each element, accessor method is defined which returns instance of `Watir::Element`
# (or subtype when applicable).  Element accessor method name is `#{element_name}_#{tag_name}`.
#
# @example Element accessors
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
#
# For each readable element, accessor method is defined which returns text of that element.
# Read accessor method name is `element_name`.
# Default readable methods are: `[:div, :span, :p, :h1, :h2, :h3, :h4, :h5, :h6,
#                                 :select_list, :text_field, :textarea, :checkbox, :radio]`.
# You can make other elements readable by adding tag names to `Watirsome.readable`.
#
# @example Read accessors
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
#
# For each clickable element, accessor method is defined which performs click on that element.
# Click accessor method name is `element_name`.
# Default clickable methods are: `[:a, :link, :button]`.
# You can make other elements clickable by adding tag names to `Watirsome.clickable`.
#
# @example Click accessors
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
#
# For each settable element, accessor method is defined which sets value to that element.
# Click accessor method name is `#{element_name}=`.
# Default settable methods are: `[:text_field, :file_field, :textarea, :checkbox, :select_list]`.
# You can make other elements settable by adding tag names to `Watirsome.settable`.
#
# @example Set accessors
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
#
# Watirsome also provides you with opportunity to locate elements by using any
# boolean method Watir element (and subelements) supports. See "Custom locators"
# example.
#
# @example Custom locators
#   class Page
#     include Watirsome
#
#     div :visible, class: 'visibility', visible: true
#     div :invisible, class: 'visibility', visible: false
#     select_list :country, selected: 'USA'
#   end
#
#   page = Page.new(@browser)
#   page.visible_div.visible?   #=> true
#   page.invisible_div.visible? #=> false
#   page.country_select_list.selected?('USA') #=> true
#
#
# Watirsome provides you with initializers API to dynamically modify your pages/regions behavior.
#
# Each page may define `#initialize_page` method which will be used as page constructor.
#
# @example Page initializer
#   class Page
#     include Watirsome
#
#     attr_accessor :page_loaded
#
#     def initialize_page
#       self.page_loaded = true
#     end
#   end
#
#   page = Page.new(@browser)
#   page.page_loaded
#   #=> true
#
#
# Each region you include/extend may define `#initialize_region` method which will
# be called after page constructor.  Regions are being cached, so, once initialized,
# they won't be executed if you call `Page#initialize_regions` again.
#
# @example Region initializer (old API using module)
#   module HeaderRegion
#     def initialize_region
#       self.page_loaded = true
#     end
#   end
#
#   class Page
#     include Watirsome
#     include HeaderRegion
#
#     attr_accessor :page_loaded
#   end
#
#   page = Page.new(@browser)
#   page.page_loaded
#   #=> true
#
# @example Region initializer (new API using classes)
#   class ProfileRegion
#     include Watirsome
#
#     attr_accessor :page_loaded
#
#     def initialize_region
#       self.page_loaded = true
#     end
#   end
#
#   class Page
#     include Watirsome
#
#     has_one :profile
#   end
#
#   page = Page.new(@browser)
#   page.profile.page_loaded
#   #=> true
#
#
# @todo Add documentation for new Regions API.
#
# @example Single region
#   class ProfileRegion
#     include Watirsome
#
#     element :region, class: 'for-profile'
#     div :name, -> { region_element.div(class: 'name') }
#   end
#
#   class Page
#     include Watirsome
#
#     has_one :profile
#   end
#
#   page = Page.new(@browser)
#   page.profile.name #=> 'John Smith'
#
# @example Multiple regions
#   class UserRegion
#     include Watirsome
#
#     div :name, -> { region_element.div(class: 'name') }
#   end
#
#   # You can skip defining this class if you want.
#   # In this case, Watirsome will return Array<UserRegion>.
#   class UsersRegion
#     include Watirsome
#   end
#
#   class Page
#     include Watirsome
#
#     has_many :users, each: {class: 'for-user'}
#   end
#
#   page = Page.new(@browser)
#   page.users.map(&:name)               #=> @browser.elements(class: 'for-user').map(&:text)
#   page.user(name: 'John Smith 1').name #=> @browser.element(class: 'for-user', index: 0).text
#   page.user(name: 'John Smith 2').name #=> @browser.element(class: 'for-user', index: 1).text
#   page.user(name: 'John Smith 3')      #=> raise RuntimeError, "No user matching: #{{name: 'John Smith 3'}}."
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
