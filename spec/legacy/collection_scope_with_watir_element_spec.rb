module CollectionScopeWithWatirElementSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}".freeze

  class UserRegion
    include Watirsome

    div :name, -> { region_element.div(class: 'name') }
  end

  class Page
    include Watirsome

    div :users, class: 'for-users'
    has_many :users, in: -> { users_div }, each: { class: ['for-user'] }
  end

  RSpec.describe Watirsome do
    specify 'collection scope with watir element' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        expect(page.users.map(&:name)).to eq ['John Smith 1', 'John Smith 2']
      end
    end
  end
end
