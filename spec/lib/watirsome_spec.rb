require 'spec_helper'

describe Watirsome do
  %w(readable clickable settable selectable).each do |method|
    describe ".#{method}" do
      it 'returns array of accessors' do
        accessors = described_class.send(method)
        accessors.should be_an(Array)
        accessors.each do |accessor|
          accessor.should be_a(Symbol)
        end
      end

      it 'allows to add custom accessors' do
        described_class.send(method) << :custom
        described_class.send(method).should include(:custom)
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
        described_class.send(:"#{method}?", tag).should == true
      end

      it "returns false if element is not #{method}" do
        described_class.send(:"#{method}?", :foo).should == false
      end
    end
  end

  describe '.watir_methods' do
    it 'returns array of watir container methods' do
      described_class.watir_methods.each do |method|
        Watir::Container.instance_methods.should include(method)
      end
    end
  end

  describe '.watirsome?' do
    it 'returns true if method is watir-contained' do
      described_class.watirsome?(:div).should == true
    end

    it 'returns false if method is not watir-contained' do
      described_class.watirsome?(:foo).should == false
    end
  end

  describe '.plural?' do
    it 'returns true if watir-contained method is plural with "s" ending' do
      described_class.plural?(:divs).should == true
    end

    it 'returns true if watir-contained method is plural with "es" ending' do
      described_class.plural?(:checkboxes).should == true
    end

    it 'returns false if watir-contained method is singular' do
      described_class.plural?(:div).should == false
    end

    it 'returns false if method is not watir-contained' do
      described_class.plural?(:foo).should == false
    end
  end

  describe '.pluralize' do
    it 'pluralizes method name with "s"' do
      described_class.pluralize(:div).should == :divs
    end

    it 'pluralizes method name with "es"' do
      described_class.pluralize(:checkbox).should == :checkboxes
    end

    it 'raises error when cannot pluralizes method' do
      -> { described_class.pluralize(:foo) }.should raise_error(Watirsome::Errors::CannotPluralizeError)
    end
  end

  context 'when included' do
    include_context :page

    it 'adds accessor class methods' do
      page.class.should respond_to(:div)
    end

    it 'does not add #extract_selector' do
      page.class.should_not respond_to(:extract_selector)
    end

    it 'adds accessor instance methods' do
      page.private_methods.should include(:grab_elements)
    end

    it 'adds regions initializer' do
      page.should respond_to(:initialize_regions)
    end
  end
end
