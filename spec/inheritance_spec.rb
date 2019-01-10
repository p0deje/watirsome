module InheritanceSpec
  class ToDoListItemBase
    include Watirsome

    span :name, role: 'name'
  end

  ToDoListItem = Class.new(ToDoListItemBase)

  class ToDoListBase
    include Watirsome

    text_field :new_item, role: 'new_item'
    button :add, role: 'add'
    has_many :items, region_class: ToDoListItem, within: { tag_name: :ul }, each: { tag_name: :li }
  end

  ToDoList = Class.new(ToDoListBase)

  class ToDoListPageBase
    include Watirsome

    URL = "data:text/html,#{File.read('support/todo_lists.html')}".freeze
    has_one :todo_list, region_class: ToDoList
  end

  ToDoListPage = Class.new(ToDoListPageBase)

  RSpec.describe Watirsome do
    it 'supports inheritance' do
      ToDoListPage.new(WatirHelper.browser).tap do |page|
        page.browser.goto page.class::URL

        expect(page.todo_list.items.count).to eq 3
        page.todo_list.new_item = 'Avocado'
        page.todo_list.add
        expect(page.todo_list.items.count).to eq 4
        expect(page.todo_list.items.last.name).to eq 'Avocado'
      end
    end
  end
end
