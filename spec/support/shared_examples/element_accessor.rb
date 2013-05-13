shared_examples_for :element_accessor do |tags|
  tags.each do |tag|
    context tag do 
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}_#{tag}", *args
      end

      it 'finds element with no locators' do
        watir.should_receive(tag).with(no_args).and_return(element)
        accessor(tag, 1).should == element
      end

      it 'finds element with single watir locator' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        accessor(tag, 2).should == element
      end

      it 'finds element with multiple watir locator' do
        watir.should_receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        accessor(tag, 3).should == element
      end

      it 'finds element with custom locator' do
        element2 = stub('element')
        plural = Watirsome.pluralize(tag)
        watir.should_receive(plural).with(id: tag, class: tag).and_return([element, element2])
        element.should_receive(:visible?).with(no_args).and_return(true)
        element2.should_receive(:visible?).with(no_args).and_return(false)
        accessor(tag, 4).should == element
      end

      it 'finds element with proc' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        accessor(tag, 5).should == element
      end

      it 'finds element with lambda' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        accessor(tag, 6).should == element
      end

      it 'finds element with block and custom arguments' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        accessor(tag, 7, tag).should == element
      end
    end
  end
end
