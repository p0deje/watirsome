$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'watirsome/version'

Gem::Specification.new do |s|
  s.name        = 'watirsome'
  s.version     = Watirsome::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Alex Rodionov'
  s.email       = 'p0deje@gmail.com'
  s.homepage    = 'http://github.com/p0deje/watirsome'
  s.summary     = 'Awesome page objects with Watir'
  s.description = 'Pure dynamic Watir-based page object DSL'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = %w[lib]

  s.add_dependency 'watir', '>= 6.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'yard-doctest', '>= 0.1.5'
end
