require 'watirsome'

YARD::Doctest.configure do |doctest|
  doctest.before do
    opts = {}
    if ENV['TRAVIS']
      Selenium::WebDriver::Chrome.path = "#{File.dirname(__FILE__)}/../bin/google-chrome"
      opts[:args] = ['no-sandbox']
    end
    @browser = Watir::Browser.new(:chrome, opts)
    @browser.goto "data:text/html,#{File.read('support/doctest.html')}"
  end

  doctest.after do
    @browser.quit
  end
end
