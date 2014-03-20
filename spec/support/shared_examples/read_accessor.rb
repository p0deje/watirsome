shared_examples_for :read_accessor do |tags|
  tags.each do |tag|
    context tag do
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}", *args
      end

      def read_expectation(tag)
        case tag
        when 'text_field'
          expect(element).to receive(:value).and_return('text')
        when 'select_list'
          option1 = double('option1', selected?: true)
          option2 = double('option2', selected?: false)
          expect(element).to receive(:options).and_return([option1, option2])
          expect(option1).to receive(:text).and_return('text')
          expect(option2).not_to receive(:text)
        else
          expect(element).to receive(:text).and_return('text')
        end
      end

      it 'gets text from element with no locators' do
        expect(watir).to receive(tag).with(no_args).and_return(element)
        read_expectation(tag)
        expect(accessor(tag, 1)).to eq('text')
      end

      it 'gets text from element with single watir locator' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        expect(accessor(tag, 2)).to eq('text')
      end

      it 'gets text from element with multiple watir locator' do
        expect(watir).to receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        read_expectation(tag)
        expect(accessor(tag, 3)).to eq('text')
      end

      it 'gets text from element with custom locator' do
        element2 = double('element', visible?: false)
        plural = Watirsome.pluralize(tag)
        expect(watir).to receive(plural).with(id: tag, class: tag).and_return([element, element2])
        read_expectation(tag)
        expect(accessor(tag, 4)).to eq('text')
      end

      it 'gets text from element with proc' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        expect(accessor(tag, 5)).to eq('text')
      end

      it 'gets text from element with lambda' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        expect(accessor(tag, 6)).to eq('text')
      end

      it 'gets text from element with block and custom arguments' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        expect(accessor(tag, 7, tag)).to eq('text')
      end
    end
  end
end
