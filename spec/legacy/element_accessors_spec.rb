module ElementAccessorsSpec
  URL = "file:///#{File.expand_path('support/doctest.html')}".freeze

  class Page
    include Watirsome

    element :body, tag_name: 'body'
    div :container, class: 'container'
  end

  RSpec.describe Watirsome do
    specify 'element accessors' do
      Page.new(WatirHelper.browser).tap do |page|
        page.browser.goto URL

        expect(page.body_element).to eq WatirHelper.browser.element(tag_name: 'body')
        expect(page.container_div).to eq WatirHelper.browser.div(class: 'container')
      end
    end
  end
end
