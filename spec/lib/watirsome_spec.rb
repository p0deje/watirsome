require 'spec_helper'

describe Watirsome do
  %w(readable clickable settable selectable).each do |method|
    describe ".#{method}" do
      it 'returns array of accessors' do
        accessors = described_class.send(method)
        expect(accessors).to be_an(Array)
        accessors.each do |accessor|
          expect(accessor).to be_a(Symbol)
        end
      end

      it 'allows to add custom accessors' do
        described_class.send(method) << :custom
        expect(described_class.send(method)).to include(:custom)
      end
    end

    describe ".#{method}?" do
      let(:tag) do
        case method
        when 'readable'   then :div
        when 'clickable'  then :button
        when 'settable'   then :text_field
        when 'selectable' then :select_list
        end
      end

      it "returns true if element is #{method}" do
        expect(described_class.send(:"#{method}?", tag)).to eq(true)
      end

      it "returns false if element is not #{method}" do
        expect(described_class.send(:"#{method}?", :foo)).to eq(false)
      end
    end
  end

  describe '.watir_methods' do
    it 'returns array of watir container methods' do
      described_class.watir_methods.each do |method|
        expect(Watir::Container.instance_methods).to include(method)
      end
    end
  end

  describe '.watirsome?' do
    it 'returns true if method is watir-contained' do
      expect(described_class.watirsome?(:div)).to eq(true)
    end

    it 'returns false if method is not watir-contained' do
      expect(described_class.watirsome?(:foo)).to eq(false)
    end
  end

  describe '.plural?' do
    it 'returns true if watir-contained method is plural with "s" ending' do
      expect(described_class.plural?(:divs)).to eq(true)
    end

    it 'returns true if watir-contained method is plural with "es" ending' do
      expect(described_class.plural?(:checkboxes)).to eq(true)
    end

    it 'returns false if watir-contained method is singular' do
      expect(described_class.plural?(:div)).to eq(false)
    end

    it 'returns false if method is not watir-contained' do
      expect(described_class.plural?(:foo)).to eq(false)
    end
  end

  describe '.pluralize' do
    it 'pluralizes method name with "s"' do
      expect(described_class.pluralize(:div)).to eq(:divs)
    end

    it 'pluralizes method name with "es"' do
      expect(described_class.pluralize(:checkbox)).to eq(:checkboxes)
    end

    it 'raises error when cannot pluralizes method' do
      expect { described_class.pluralize(:foo) }.to raise_error(Watirsome::Errors::CannotPluralizeError)
    end
  end

  context 'when included' do
    include_context :page

    it 'adds accessor class methods' do
      expect(page.class).to respond_to(:div)
    end

    it 'does not add #extract_selector' do
      expect(page.class).not_to respond_to(:extract_selector)
    end

    it 'adds accessor instance methods' do
      expect(page.private_methods).to include(:grab_elements)
    end

    it 'adds regions initializer' do
      expect(page).to respond_to(:initialize_regions)
    end
  end
end
