# frozen_string_literal: true

module SetAccessorsSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}"

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
