require 'spec_helper'

describe Watirsome::Accessors do
  include_context :page
  include_context :element

  it_defines :element_accessor, %w(div a text_field select_list)
  it_defines :read_accessor,    %w(div text_field select_list)
  it_defines :click_accessor,   %w(a)
  it_defines :set_accessor,     %w(text_field checkbox)
  it_defines :select_accessor,  %w(select_list)

  it 'supports subtype custom locators' do
    element2 = double('element')
    expect(watir).to receive(:select_lists).with(id: 'select_list').and_return([element, element2])
    expect(element).to receive(:selected?).with('Test').and_return(true)
    expect(element2).to receive(:selected?).with('Test').and_return(false)
    expect(page.select_list8_select_list).to eq(element)
  end
end
