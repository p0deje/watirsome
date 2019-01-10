module CollectionRegionUsingClassSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class UserRegion
    include Watirsome

    div :name, -> { region_element.div(class: 'name') }
  end

  class Page
    include Watirsome

    has_many :users, each: { class: 'for-user' }
  end

  RSpec.describe Watirsome do
    specify 'collection region using class' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        # You can use collection region as an array.
        expect(page.users.size).to eq 2
        expect(page.users.map(&:name)).to eq ['John Smith 1', 'John Smith 2']

        # You can search for particular regions in collection.
        expect(page.user(name: 'John Smith 1').name).to eq 'John Smith 1'
        expect(page.user(name: 'John Smith 2').name).to eq 'John Smith 2'
        expect { page.user(name: 'John Smith 3') }.to raise_error(RuntimeError, /No user matching:/)
      end
    end
  end
end
