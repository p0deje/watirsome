require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/spec/" 
  add_filter "/vendor/" 
end

require 'watir-webdriver'
require 'watirsome'

Dir['spec/support/**/*.rb'].each do |file|
  require file.sub(/spec\//, '')
end

RSpec.configure do |spec|
  spec.alias_it_should_behave_like_to :it_defines, 'it defines'
  
  shared_context :page do
    let(:watir) { stub('watir')    }
    let(:page)  { Page.new(watir)  }
  end
  
  shared_context :element do
    let(:element) { stub('element', visible?: true) }
  end
end
