module RegionInitializerNewApiSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class ProfileRegion
    include Watirsome

    attr_reader :page_loaded

    def initialize_region
      @page_loaded = true
    end
  end

  class Page
    include Watirsome

    has_one :profile
  end

  RSpec.describe Watirsome do
    specify 'region initializer new API' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.profile.page_loaded).to be true
      end
    end
  end
end
