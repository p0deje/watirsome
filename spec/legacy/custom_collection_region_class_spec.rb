module CustomCollectionRegionClassSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class UserRegion
    include Watirsome

    div :name, -> { region_element.div(class: 'name') }
  end

  class UsersRegion
    include Watirsome

    def two?
      region_collection.size == 2
    end
  end

  class Page
    include Watirsome

    has_many :users, each: { class: 'for-user' }
  end

  RSpec.describe Watirsome do
    specify 'custom collection region class' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.users.two?).to be true
        expect(page.users.map(&:name)).to eq ['John Smith 1', 'John Smith 2']
        # You can access parent collection region from children too.
        expect(page.user(name: 'John Smith 1').parent.two?).to be true
      end
    end
  end
end
