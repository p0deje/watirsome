module CollectionScopeWithWatirSelectorSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}".freeze

  class UserRegion
    include Watirsome

    div :name, -> { region_element.div(class: 'name') }
  end

  class Page
    include Watirsome

    has_many :users, in: { class: 'for-users' }, each: { class: ['for-user'] }
  end

  RSpec.describe Watirsome do
    specify 'collection scope with watir selector' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        expect(page.users.map(&:name)).to eq ['John Smith 1', 'John Smith 2']
      end
    end
  end
end
