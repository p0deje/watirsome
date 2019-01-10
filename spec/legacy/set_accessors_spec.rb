module SetAccessorsSpec
  URL = "data:text/html,#{File.read('support/doctest.html')}".freeze

  class Page
    include Watirsome

    text_field :name, placeholder: 'Enter your name'
    select_list :country, name: 'Country'
    checkbox :agree, name: 'I Agree'
  end

  RSpec.describe Watirsome do
    specify 'set accessors' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        page.name = 'My name'
        expect(page.name).to eq 'My name'
        page.country = 'Russia'
        expect(page.country).to eq 'Russia'
        page.agree = true
        expect(page.agree).to be true
      end
    end
  end
end
