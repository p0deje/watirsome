# frozen_string_literal: true

require 'watir'
require 'pry'
require_relative '../lib/watirsome'
require 'webdrivers'

class WatirHelper
  class << self
    def browser
      @browser ||= Watir::Browser.new(:chrome)
    end
  end
end

Watir.default_timeout = 3

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  config.after(:suite) do
    WatirHelper.browser.quit
  end
end
