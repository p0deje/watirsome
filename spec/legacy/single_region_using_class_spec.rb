module SingleRegionUsingClassSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class ProfileRegion
    include Watirsome

    element :wrapper, class: 'for-profile'
    div :name, -> { wrapper_element.div(class: 'name') }
  end

  class Page
    include Watirsome

    has_one :profile
  end

  RSpec.describe Watirsome do
    it 'single region using class' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.profile.name).to eq 'John Smith'
      end
    end
  end
end
