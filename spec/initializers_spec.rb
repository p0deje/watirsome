module InitializersSpec
  class InitializedRegion
    include Watirsome

    attr_reader :ready

    def initialize_region
      @ready = true
    end
  end

  class InitializedPage
    include Watirsome

    attr_reader :ready

    URL = "data:text/html,#{File.read('support/greeter.html')}".freeze

    has_one :region, region_class: InitializedRegion

    def initialize_page
      @ready = true
    end
  end

  RSpec.describe Watirsome do
    it '.intialize_page' do
      InitializedPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL
        expect(page.ready).to be true
      end
    end

    it '.intialize_region' do
      InitializedPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL
        expect(page.region.ready).to be true
      end
    end
  end
end
