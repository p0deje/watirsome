shared_examples_for :click_accessor do |tags|
  tags.each do |tag|
    context tag do
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}", *args
      end

      it 'clicks element with no locators' do
        expect(watir).to receive(tag).with(no_args).and_return(element)
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 1)
      end

      it 'clicks element with single watir locator' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 2)
      end

      it 'clicks element with multiple watir locator' do
        expect(watir).to receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 3)
      end

      it 'clicks element with custom locator' do
        element2 = double('element', visible?: false)
        plural = Watirsome.pluralize(tag)
        expect(watir).to receive(plural).with(id: tag, class: tag).and_return([element, element2])
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 4)
      end

      it 'clicks element with proc' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 5)
      end

      it 'clicks element with lambda' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 6)
      end

      it 'clicks element with block and custom arguments' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:click).with(any_args)
        accessor(tag, 7, tag)
      end
    end
  end
end
