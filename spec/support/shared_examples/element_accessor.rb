shared_examples_for :element_accessor do |tags|
  tags.each do |tag|
    context tag do
      def accessor(tag, index, *args)
        page.send :"#{tag}#{index}_#{tag}", *args
      end

      it 'finds element with no locators' do
        expect(watir).to receive(tag).with(no_args).and_return(element)
        expect(accessor(tag, 1)).to eq(element)
      end

      it 'finds element with single watir locator' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(accessor(tag, 2)).to eq(element)
      end

      it 'finds element with multiple watir locator' do
        expect(watir).to receive(tag).with(id: tag, class: /#{tag}/).and_return(element)
        expect(accessor(tag, 3)).to eq(element)
      end

      it 'finds element with custom locator' do
        element2 = double('element')
        plural = Watirsome.pluralize(tag)
        expect(watir).to receive(plural).with(id: tag, class: tag).and_return([element, element2])
        expect(element).to receive(:visible?).and_return(true)
        expect(element2).to receive(:visible?).and_return(false)
        expect(accessor(tag, 4)).to eq(element)
      end

      it 'finds element with proc' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(accessor(tag, 5)).to eq(element)
      end

      it 'finds element with lambda' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(accessor(tag, 6)).to eq(element)
      end

      it 'finds element with block and custom arguments' do
        expect(watir).to receive(tag).with(id: tag).and_return(element)
        expect(accessor(tag, 7, tag)).to eq(element)
      end
    end
  end
end
