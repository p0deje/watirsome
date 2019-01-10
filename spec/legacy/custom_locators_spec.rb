module CustomLocatorsSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class Page
    include Watirsome

    div :visible, class: 'visibility', visible: true
    div :invisible, class: 'visibility', visible: false
    select_list :country, selected: 'USA'
  end

  RSpec.describe Watirsome do
    specify 'custom locators' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        expect(page.visible_div.present?).to be true
        expect(page.invisible_div.present?).to be false
        expect(page.country_select_list.selected?('USA')).to be true
      end
    end
  end
end
