require 'spec_helper'

describe Watirsome::Initializers do
  include_context :page

  describe '#initialze' do
    it 'does not initalize page if there is no constructor defined' do
      page = Page.dup
      page.class_eval { remove_method :initialize_page }
      expect(page).not_to receive(:initialize_page)
      page.new(watir)
    end

    it 'initializes page if there is constructor defined' do
      expect(page.instance_variable_get(:@initialized)).to eq(true)
    end

    it 'initalizes regions' do
      expect_any_instance_of(Page).to receive(:initialize_regions)
      Page.new(watir)
    end
  end

  describe '#initialize_regions' do
    it 'initalizes included regions' do
      expect(page.instance_variable_get(:@included_initialized)).to eq(1)
    end

    it 'initalizes extended regions' do
      expect(page.instance_variable_get(:@extended_initialized)).to eq(1)
    end

    it 'caches initalized regions' do
      page.initialize_regions
      expect(page.instance_variable_get(:@included_initialized)).to eq(1)
    end
  end
end
