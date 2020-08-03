# frozen_string_literal: true

module HasOneSpec
  class ToDoListItem
    include Watirsome

    span :name, role: 'name'
  end

  class ToDoList
    include Watirsome

    div :title, role: 'title'
    has_one :item, class: ToDoListItem, in: { tag_name: :li }
  end

  class TodoListDefaultRegion
    include Watirsome

    div :title, role: 'title'
    has_one :item, class: ToDoListItem, in: { tag_name: :li }
  end

  class ToDoListPage
    include Watirsome

    URL = "file:///#{File.expand_path('support/todo_lists.html')}"
    has_one :todo_list, region_class: ToDoList, within: { id: 'todos_work' }
    has_one :todo_list_default, within: -> { browser.element(id: 'todos_work') }
    has_one :todo_list_inline, within: -> { region_element.element(id: 'todos_work') } do
      div :title, role: 'title'
      has_one :item, within: { tag_name: :li } do
        span :name, role: 'name'
      end
    end

    has_one :home_todo_list, region_class: ToDoList, within: { id: 'todos_home' }

    has_one :movies_todo_list, within: { id: 'todos_movies', visible: true } do
      has_many :items, each: { tag_name: :li } do
        span :name, role: 'name'
      end
    end

    def home_todo_list
      super.title
    end
  end

  #############################################

  RSpec.describe '.has_one' do
    it 'supports region_class parameter' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list).to be_a ToDoList
        expect(page.todo_list.title).to eq 'Work'
      end
    end

    it 'supports inline region class (with nesting)' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list_inline.title).to eq 'Work'
        expect(page.todo_list.item.name).to eq 'Review the PR-1234'
      end
    end

    it 'supports region class inferred from the region name' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list_default).to be_a TodoListDefaultRegion
        expect(page.todo_list_default.title).to eq 'Work'
      end
    end

    it 'supports nesting' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list.item).to be_a ToDoListItem
        expect(page.todo_list.item.name).to eq 'Review the PR-1234'
      end
    end

    it 'supports calling super' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL
        expect(page.home_todo_list).to eq 'Home'
      end
    end

    it 'waits for the element scope' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL
        expect(page.movies_todo_list.items.first.name).to eq 'The Shawshank Redemption'
      end
    end
  end
end
