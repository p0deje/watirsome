## watirsome [![Gem Version](https://badge.fury.io/rb/watirsome.svg)](http://badge.fury.io/rb/watirsome) [![Build Status](https://secure.travis-ci.org/p0deje/watirsome.svg)](http://travis-ci.org/p0deje/watirsome)

Pure dynamic Watir-based page object DSL.

Inspired by [page-object](https://github.com/cheezy/page-object) and [watir-page-helper](https://github.com/alisterscott/watir-page-helper).

### Installation

Just like any other gem:

```shell
➜ gem install watirsome
```

Or using bundler:

```ruby
# Gemfile
gem 'watirsome'
```

### Examples

```ruby
class LoginPage
  include Watirsome

  text_field :username, label: 'Username'
  text_field :password, label: 'Password'
  button :submit_login, text: 'Login'

  def login(username, password)
    self.username = username
    self.password = password
    submit_login
  end
end

browser = Watir::Browser.new
page = LoginPage.new(browser)
page.login('demo', 'demo')
```

### Accessors

Watirsome provides you with accessors DSL to isolate elements from your methods.

All accessors are just proxied to Watir, thus you free to use all its power in your page objects.

```ruby
class Page
  include Watirsome

  # any method defined in Watir::Container are accessible
  body :body
  section :section, id: 'section_one'
  element :svg, tag_name: 'svg'
end
```

#### Locators

You can use any kind of locators you use with Watir.

```ruby
class Page
  include Watirsome

  body :body
  section :one, id: 'section_one'
  element :svg, tag_name: 'svg'
  button :login, class: 'submit', index: 1
end

page = Page.new(@browser)
page.body_body     # equals to @browser.body
page.one_section   # equals to @browser.section(id: 'section_one')
page.svg_element   # equals to @browser.element(tag_name: 'svg')
page.login_button  # equals to @browser.button(class: 'submit', index: 1)
```

Watirsome also provides you with opportunity to locate elements by using any boolean method Watir element (and subelements) supports.

```ruby
class Page
  include Watirsome

  div :layer, class: 'layer', visible: true
  span :wrapper, exists: false
  select_list :country, selected: 'Please select country...'
end

page = Page.new(@browser)
page.layer_div           # equals to @browser.divs(class: 'layer').find { |e| e.visible? == true }
page.wrapper_span        # equals to @browser.spans.find { |e| e.exists? == false }
page.country_select_list # equals to @browser.select_lists.find { |e| e.selected?('Please select country...') }
```

You can also use proc/lambda/block to locate element. Block is executed in the context of initialized page, so other accessors can be used.

```ruby
class Page
  include Watirsome

  div :layer, class: 'layer'
  span :wrapper, -> { layer_div.span(class: 'span') }
end

page = Page.new(@browser)
page.wrapper_span  # equals to @browser.div(class: 'layer').span(class: 'span')
```

Moreover, you can pass arguments to blocks!

```ruby
class Page
  include Watirsome

  div :layer, class: 'layer'
  a :link do |text|
    layer_div.a(text: text)
  end
end

page = Page.new(@browser)
page.link_a('Login')  # equals to @browser.div(class: 'layer').a(text: 'Login')
```

#### Element Accessors

For each element, accessor method is defined which returns instance of `Watir::Element` (or subtype when applicable).

Element accessor method name is `#{element_name}_#{tag_name}`.

```ruby
class Page
  include Watirsome

  section :section_one, id: 'section_one'
  element :svg, tag_name: 'svg'
end

page = Page.new(@browser)
page.section_one_section  #=> #<Watir::HTMLElement:0x201b2f994f32c922 selector={:tag_name=>"section"}>
page.svg_element          #=> #<Watir::HTMLElement:0x15288276ab771162 selector={:tag_name=>"svg"}>
```

#### Readable Accessors

For each readable element, accessor method is defined which returns text of that element.

Read accessor method name is `element_name`.

Default readable methods are: `[:div, :span, :p, :h1, :h2, :h3, :h4, :h5, :h6, :select_list, :text_field, :textarea, :checkbox, :radio]`.

You can make other elements readable by adding tag names to `Watirsome.readable`.

```ruby
# make section readable
Watirsome.readable << :section

class Page
  include Watirsome

  div :main, id: 'main_div'
  section :date, id: 'date'
end

page = Page.new(@browser)
page.main  # returns text of main div
page.date  # returns text of date section
```

There is a bit of logic behind text retrieval:

1. If element is a text field or textarea, return value
2. If element is a select list, return text of first selected option
3. Otherwise, return text

#### Clickable Accessors

For each clickable element, accessor method is defined which performs click on that element.

Click accessor method name is `element_name`.

Default clickable methods are: `[:a, :link, :button]`.

You can make other elements clickable by adding tag names to `Watirsome.clickable`.

```ruby
# make input clickable
Watirsome.clickable << :input

class Page
  include Watirsome

  a :login, text: 'Login'
  input :submit, ->(type) { @browser.input(type: type) }
end

page = Page.new(@browser)
page.login             # clicks on link
page.submit('submit')  # clicks on submit input
```

#### Settable Accessors

For each settable element, accessor method is defined which sets value to that element.

Click accessor method name is `#{element_name}=`.

Default settable methods are: `[:text_field, :file_field, :textarea, :checkbox, :select_list]`.

You can make other elements settable by adding tag names to `Watirsome.settable`.

```ruby
# make input settable
Watirsome.settable << :input

class Page
  include Watirsome

  text_field :username, label: 'Username'
  input :date, type: 'date'
  select_list :country, label: 'Country'
end

page = Page.new(@browser)
page.username = 'Username'         # sets value of username text field
page.date = '2013-01-01', :return  # sends text to element and hits "Enter"
page.country = 'Russia'            # selects option with "Russia" text
```

If found element responds to `#set`, accessor calls it. Otherwise, `#send_keys` is used.

### Initializers

Watirsome provides you with initializers DSL to dynamically modify your pages/regions behavior.

#### Page Initializer

Each page may define `#initialize_page` method which will be used as page constructor.

```ruby
class Page
  include Watirsome

  def initialize_page
    puts 'Initialized!'
  end
end

Page.new(@browser)
#=> 'Initialized!'
```

#### Region Initializer

Each region you include/extend may define `#initialize_region` method which will be called after page constructor.


```ruby
module HeaderRegion
  def initialize_region
    puts 'Initialzed header!'
  end
end

module FooterRegion
  def initialize_region
    puts 'Initialzed footer!'
  end
end

class Page
  include Watirsome
  include HeaderRegion

  def initialize_page
    extend FooterRegion
  end
end

Page.new(@browser)
#=> 'Initialized header!'
#=> 'Initialized footer!'
```

Regions are being cached, so, once initialized, they won't be executed if you call `Page#initialize_regions` again.

### Limitations

1. You cannot use `Watir::Browser#select` method as it's overriden by `Kernel#select`. Use `Watir::Browser#select_list` instead.
2. You cannot use block arguments to locate elements for settable/selectable accessors (it makes no sense). However, you can use block arguments for all other accessors.

### Contribute

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright (c) 2016 Alex Rodionov. See LICENSE.md for details.
