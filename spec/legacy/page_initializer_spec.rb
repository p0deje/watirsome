# frozen_string_literal: true

module PageInitializerSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}"

  class Page
    include Watirsome

    attr_accessor :page_loaded

    def initialize_page
      self.page_loaded = true
    end
  end

  RSpec.describe Watirsome do
    specify 'page initializer' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.page_loaded).to be true
      end
    end
  end
end
