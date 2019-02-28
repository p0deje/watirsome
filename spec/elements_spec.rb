module ElementsSpec
  class GreetingPage
    include Watirsome

    URL = "file:///#{File.expand_path('support/greeter.html')}".freeze

    text_field :name, id: 'name'
    button :set, id: 'set_name'
    div :greeting, id: 'greeting'

    text_field :name2, -> { region_element.text_field(id: 'name') }
    button :set2, -> { region_element.button(id: 'set_name') }
    div :greeting2, -> { region_element.div(id: 'greeting') }
  end

  RSpec.describe Watirsome do
    it 'supports settable elements' do
      GreetingPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        page.name = 'Bob'
        expect(page.name).to eq 'Bob'
        expect(page.name_text_field).to be_a Watir::TextField
      end
    end

    it 'supports settable elements (lambda)' do
      GreetingPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        page.name2 = 'Bob'
        expect(page.name2).to eq 'Bob'
        expect(page.name2_text_field).to be_a Watir::TextField
      end
    end

    it 'supports readable elements' do
      GreetingPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto 'about#blank'
        page.browser.goto page.class::URL

        expect(page.greeting).to eq 'Hello stranger!'
        expect(page.greeting_div).to be_a Watir::Div
      end
    end

    it 'supports readable elements (lambda)' do
      GreetingPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto 'about#blank'
        page.browser.goto page.class::URL

        expect(page.greeting2).to eq 'Hello stranger!'
        expect(page.greeting2_div).to be_a Watir::Div
      end
    end

    it 'supports clickable elements' do
      GreetingPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        page.name = 'Bob'
        page.set
        expect(page.greeting).to eq 'Hello Bob!'
        expect(page.set_button).to be_a Watir::Button
      end
    end

    it 'supports clickable elements (lambda)' do
      GreetingPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        page.name2 = 'Bob'
        page.set2
        expect(page.greeting2).to eq 'Hello Bob!'
        expect(page.set2_button).to be_a Watir::Button
      end
    end
  end
end
