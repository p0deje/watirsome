shared_examples_for :read_accessor do |tags|
  tags.each do |tag|
    context tag do 
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}", *args
      end
      
      def read_expectation(tag)
        case tag
        when 'text_field'
          element.should_receive(:value).and_return('text')  
        when 'select_list'
          option1 = stub('option1', selected?: true)
          option2 = stub('option2', selected?: false)
          element.should_receive(:options).and_return([option1, option2])
          option1.should_receive(:text).and_return('text')
          option2.should_not_receive(:text)
        else
          element.should_receive(:text).and_return('text')  
        end
      end

      it 'gets text from element with no locators' do
        watir.should_receive(tag).with(no_args).and_return(element)
        read_expectation(tag)
        accessor(tag, 1).should == 'text'
      end

      it 'gets text from element with single watir locator' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        accessor(tag, 2).should == 'text'
      end

      it 'gets text from element with multiple watir locator' do
        watir.should_receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        read_expectation(tag)
        accessor(tag, 3).should == 'text'
      end

      it 'gets text from element with custom locator' do
        element2 = stub('element', visible?: false)
        plural = Watirsome.pluralize(tag)
        watir.should_receive(plural).with(id: tag, class: tag).and_return([element, element2])
        read_expectation(tag)
        accessor(tag, 4).should == 'text'
      end

      it 'gets text from element with proc' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        accessor(tag, 5).should == 'text'
      end

      it 'gets text from element with lambda' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        accessor(tag, 6).should == 'text'
      end

      it 'gets text from element with block and custom arguments' do
        watir.should_receive(tag).with(id: tag).and_return(element)
        read_expectation(tag)
        accessor(tag, 7, tag).should == 'text'
      end
    end
  end
end
