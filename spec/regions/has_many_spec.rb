module HasManySpec
  class ToDoListItem
    include Watirsome

    span :name, role: 'name'
  end

  class ToDoList
    include Watirsome

    div :title, role: 'title'
    has_many :items, region_class: ToDoListItem, each: { tag_name: :li }
  end

  class TodoList2Region
    include Watirsome

    div :title, role: 'title'
    has_many :items, class: ToDoListItem, each: { tag_name: :li }
  end

  class TodoList2sRegion
    include Watirsome
  end

  class ToDoListCollection
    include Watirsome

    def a_custom_method
      :value
    end
  end

  class ToDoListPage
    include Watirsome

    URL = "data:text/html,#{File.read('support/todo_lists.html')}".freeze

    has_many :todo_lists, region_class: ToDoList, each: { role: 'todo_list' }
    has_many :todo_list2s, each: { role: 'todo_list' }
    has_many :todo_list_inlines, each: { role: 'todo_list' } do
      div :title, role: 'title'
      has_many :items, class: ToDoListItem, each: { tag_name: :li }
    end

    has_many :wrapped_todo_lists, through: ToDoListCollection, class: ToDoList, each: { role: 'todo_list' }
  end

  ######################################################

  RSpec.describe '.has_many' do
    it 'supports region_class parameter' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_lists.last.class).to eq ToDoList
        expect(page.todo_lists.last.title).to eq 'Groceries'
        expect(page.todo_lists.count).to eq 3
      end
    end

    it 'supports inline region class' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list_inlines.count).to eq 3
        expect(page.todo_list_inlines.last.title).to eq 'Groceries'
        expect(page.todo_list_inlines.last.items.first.name).to eq 'Bread'
      end
    end

    it 'supports region/collection class inferred from the region name' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list2s).to be_a TodoList2sRegion
        expect(page.todo_list2s.region_collection.last).to be_a TodoList2Region
        expect(page.todo_list2s.region_collection.last.title).to eq 'Groceries'
        expect(page.todo_list2s.region_collection.count).to eq 3
      end
    end

    it 'supports collection_class parameter' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.wrapped_todo_lists).to be_a ToDoListCollection
        expect(page.wrapped_todo_lists.a_custom_method).to eq :value
        expect(page.wrapped_todo_lists.first).to be_a ToDoList
      end
    end

    it 'supports nesting' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_lists.last.items.first).to be_a ToDoListItem
        expect(page.todo_lists.last.items.first.name).to eq 'Bread'
        expect(page.todo_lists.last.items.count).to eq 3
      end
    end
  end
end
