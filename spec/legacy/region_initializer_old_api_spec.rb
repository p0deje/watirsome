module RegionInitializerOldApiSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  module HeaderRegion
    def initialize_region
      self.page_loaded = true
    end
  end

  class Page
    include Watirsome
    include HeaderRegion

    attr_accessor :page_loaded
  end

  RSpec.describe Watirsome do
    specify 'region initializer old API' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.page_loaded).to be true
      end
    end
  end
end
