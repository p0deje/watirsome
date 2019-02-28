module CollectionRegionUsingBlockSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}".freeze

  class Page
    include Watirsome

    has_many :users, each: { class: 'for-user' } do
      div :name, -> { region_element.div(class: 'name') }
    end
  end

  RSpec.describe Watirsome do
    specify 'collection region using block' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        # You can use collection region as an array.
        expect(page.users.size).to eq 2
        expect(page.users.map(&:name)).to eq ['John Smith 1', 'John Smith 2']
      end
    end
  end
end
