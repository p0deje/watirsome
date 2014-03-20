shared_examples_for :select_accessor do |tags|
  tags.each do |tag|
    context tag do
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}=", *args
      end

      it 'selects option for element with no locators' do
        expect(watir).to receive(tag).with(no_args).and_return(element)
        expect(element).to receive(:select).with('value')
        accessor(tag, 1, 'value')
      end

      it 'selects option for element with single watir locator' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:select).with('value')
        accessor(tag, 2, 'value')
      end

      it 'selects option for element with multiple watir locator' do
        expect(watir).to receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        expect(element).to receive(:select).with('value')
        accessor(tag, 3, 'value')
      end

      it 'selects option for element with custom locator' do
        element2 = double('element', visible?: false)
        plural = Watirsome.pluralize(tag)
        expect(watir).to receive(plural).with(id: tag, class: tag).and_return([element, element2])
        expect(element).to receive(:select).with('value')
        accessor(tag, 4, 'value')
      end

      it 'selects option for element with proc' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:select).with('value')
        accessor(tag, 5, 'value')
      end

      it 'selects option for element with lambda' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(element).to receive(:select).with('value')
        accessor(tag, 6, 'value')
      end
    end
  end
end
