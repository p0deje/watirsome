require 'spec_helper'

describe Watirsome::Accessors do
  include_context :page
  include_context :element
  
  it_defines :element_accessor, %w(div a text_field select_list)
  it_defines :read_accessor,    %w(div text_field select_list)
  it_defines :click_accessor,   %w(a)
  it_defines :set_accessor,     %w(text_field checkbox)
  it_defines :select_accessor,  %w(select_list)
end
