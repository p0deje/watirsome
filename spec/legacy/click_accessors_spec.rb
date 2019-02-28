module ClickAccessorsSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}".freeze

  class Page
    include Watirsome

    a :open_google, text: 'Open Google'
  end

  RSpec.describe Watirsome do
    specify 'click accessors' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        page.open_google
        expect(page.browser.title).to eq 'Google'
      end
    end
  end
end
