# frozen_string_literal: true

RSpec.describe Watirsome do
  specify '.clickable?' do
    expect(Watirsome.clickable?(:button)).to eq true
    expect(Watirsome.clickable?(:div)).to eq false
  end

  specify '.settable?' do
    expect(Watirsome.settable?(:text_field)).to eq true
    expect(Watirsome.settable?(:button)).to eq false
  end

  specify '.readable?' do
    expect(Watirsome.readable?(:div)).to eq true
    expect(Watirsome.readable?(:body)).to eq false
  end

  specify '.watirsome?' do
    expect(Watirsome.watirsome?(:div)).to eq true
    expect(Watirsome.watirsome?(:to_a)).to eq false
  end

  specify '.plural?' do
    expect(Watirsome.plural?(:divs)).to eq true
    expect(Watirsome.plural?(:div)).to eq false
  end

  specify '.pluralize?' do
    expect(Watirsome.pluralize(:div)).to eq :divs
    expect(Watirsome.pluralize(:checkbox)).to eq :checkboxes
  end
end
