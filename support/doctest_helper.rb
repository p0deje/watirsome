require 'watirsome'

YARD::Doctest.configure do |doctest|
  doctest.before do
    @browser = Watir::Browser.new(:phantomjs)
    @browser.goto "data:text/html,#{File.read('support/doctest.html')}"
  end

  doctest.after do
    @browser.quit
  end
end
