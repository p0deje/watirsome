require 'spec_helper'

describe Watirsome::Initializers do
  include_context :page

  describe '#initialze' do
    it 'does not initalize page if there is no constructor defined' do
      page = Page.dup
      page.class_eval { remove_method :initialize_page }
      page.should_not_receive :initialize_page
      page.new(watir)
    end

    it 'initializes page if there is constructor defined' do
      page.instance_variable_get(:@initialized).should == true
    end
    
    it 'initalizes regions' do
      Page.any_instance.should_receive :initialize_regions
      Page.new(watir)
    end
  end
  
  describe '#initialize_regions' do
    it 'initalizes included regions' do
      page.instance_variable_get(:@included_initialized).should == 1
    end
    
    it 'initalizes extended regions' do
      page.instance_variable_get(:@extended_initialized).should == 1
    end
    
    it 'does not initalize modules with incorrect name' do
      page.instance_variable_get(:@helper_initialized).should == nil
    end
    
    it 'uses Watirsome.region_matcher to match module name' do
      Watirsome.should_receive(:region_matcher).and_return ''
      page
    end
    
    it 'caches initalized regions' do
      page.initialize_regions
      page.instance_variable_get(:@included_initialized).should == 1
    end
  end
end
