shared_examples_for :click_accessor do |tags|
  tags.each do |tag|
    context tag do 
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}", *args
      end

      it 'clicks element with no locators' do
        watir.should_receive(tag).with(no_args).and_return(element)
        element.should_receive(:click).with(any_args)
        accessor(tag, 1)
      end

      it 'clicks element with single watir locator' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        element.should_receive(:click).with(any_args)
        accessor(tag, 2)
      end

      it 'clicks element with multiple watir locator' do
        watir.should_receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        element.should_receive(:click).with(any_args)
        accessor(tag, 3)
      end

      it 'clicks element with custom locator' do
        element2 = stub('element', visible?: false)
        plural = Watirsome.pluralize(tag)
        watir.should_receive(plural).with(id: tag, class: tag).and_return([element, element2])
        element.should_receive(:click).with(any_args)
        accessor(tag, 4)
      end

      it 'clicks element with proc' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        element.should_receive(:click).with(any_args)
        accessor(tag, 5)
      end

      it 'clicks element with lambda' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        element.should_receive(:click).with(any_args)
        accessor(tag, 6)
      end

      it 'clicks element with block and custom arguments' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        element.should_receive(:click).with(any_args)
        accessor(tag, 7, tag)
      end
    end
  end
end
