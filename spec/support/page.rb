module IncludedRegion
  def initialize_region
    @included_initialized ||= 0
    @included_initialized += 1
  end
end # IncludedRegion


module ExtendedRegion
  def initialize_region
    @extended_initialized = 1
  end
end # ExtendedRegion


module Helper
  def initialize_region
    @helper_initialized = 1
  end
end # Helper


class Page
  include Watirsome
  include IncludedRegion
  include Helper

  def initialize_page
    extend ExtendedRegion
    @initialized = true
  end

  %w(div a text_field checkbox select_list).each do |tag|
    send tag, :"#{tag}1"
    send tag, :"#{tag}2", id: tag
    send tag, :"#{tag}3", id: tag, class: /#{tag}/
    send tag, :"#{tag}4", id: tag, class: tag, visible: true
    send tag, :"#{tag}5", proc { @browser.send(tag, id: tag) }
    send tag, :"#{tag}6", -> { @browser.send(tag, id: tag) }
    # set/select accessor cannot have block arguments
    case tag
    when 'div', 'a'
      send(tag, :"#{tag}7") { |id| @browser.send(tag, id: id) }    
    when 'text_field', 'select_list'
      send(tag, :"#{tag}7") { @browser.send(tag, id: tag) }    
    end
  end

end # Page
