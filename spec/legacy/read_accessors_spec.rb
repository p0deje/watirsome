# frozen_string_literal: true

module ReadAccessorsSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}"

  class Page
    include Watirsome

    div :container, class: 'container'
    radio :sex_male, value: 'Male'
  end

  RSpec.describe Watirsome do
    specify 'read accessors' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL
        expect(page.container).to eq 'Container'
        page.sex_male_radio.set
        expect(page.sex_male).to be true
      end
    end
  end
end
