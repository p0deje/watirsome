require 'watirsome'

def browser
  @browser ||= begin
    browser = Watir::Browser.new(:phantomjs)
    browser.goto "data:text/html,#{File.read('support/doctest.html')}"

    browser
  end
end

YARD::Doctest.configure do |doctest|
  doctest.after do
    @browser.quit if @browser
  end
end
