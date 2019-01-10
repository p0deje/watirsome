module CollectionRegionFromItselfSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class UserRegion
    include Watirsome

    div :name, -> { region_element.div(class: 'name') }
  end

  class UsersRegion
    include Watirsome

    def first_half
      self.class.new(@browser, region_element, region_collection.each_slice(1).to_a[0])
    end

    def second_half
      self.class.new(@browser, region_element, @browser.divs(class: 'for-user').each_slice(1).to_a[1])
    end
  end

  class Page
    include Watirsome

    has_many :users, each: { class: 'for-user' }
  end

  RSpec.describe Watirsome do
    it 'returns collection region from itself' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        expect(page.users.first_half.map(&:name)).to eq ['John Smith 1']
        expect(page.users.second_half.map(&:name)).to eq ['John Smith 2']
      end
    end
  end
end
