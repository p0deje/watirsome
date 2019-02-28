module SingleRegionUsingBlock
  URL = "file:///#{File.expand_path('support/doctest.html')}".freeze

  class Page
    include Watirsome

    has_one :profile do
      element :wrapper, class: 'for-profile'
      div :name, -> { wrapper_element.div(class: 'name') }
    end
  end

  RSpec.describe Watirsome do
    it 'single region using block' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.profile.name).to eq 'John Smith'
      end
    end
  end
end
