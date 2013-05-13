## watirsome [![Gem Version](https://badge.fury.io/rb/watirsome.png)](http://badge.fury.io/rb/watirsome) [![Build Status](https://secure.travis-ci.org/p0deje/watirsome.png)](http://travis-ci.org/p0deje/watirsome) [![Coverage Status](https://coveralls.io/repos/p0deje/watirsome/badge.png?branch=master)](https://coveralls.io/r/p0deje/watirsome)

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
class Page
  include Watirsome
  
  text_field :username, label: 'Username'
  text_field :password, label: 'Password'
  button :login, text: 'Login'
  
  def login(username, password)
    self.username = username
    self.password = password
    login
  end
end
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
page.body_element  # equals to @browser.body
page.section_one   # equals to @browser.section(id: 'section')
page.svg_element   # equals to @browser.element(tag_name: 'svg')
page.login_button  # equals to @browser.button(class: 'submit', index: 1)
```

Watirsome also provides you with opportunity to locate elements by using any boolean method Watir element supports.

```ruby
class Page
  include Watirsome
  
  div :layer, class: 'layer', visible: true    
  span :wrapper, class: 'span', exists: false  
end

page = Page.new(@browser)
page.layer_div     # equals to @browser.divs(class: 'layer').find { |e| e.visible? == true }
page.wrapper_span  # equals to @browser.divs(class: 'layer').find { |e| e.exists? == false }
```

You can also use proc/lambda/block to locate element. Block is executed in the context of initalized page, so other accessors can be used.

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

#### Element accessors

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

#### Readable accessors

For each redable element, accessor method is defined which returns text of that element.

Read accessor method name is `element_name`.

Default redable methods are: `[:div, :span, :p, :h1, :h2, :h3, :h4, :h5, :h6, :select_list, :text_field, :textarea]`.

You can make other elements redable by adding tag names to `Watirsome.redable`.

```ruby
# make section redable
Watirsome.redable << :section

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

#### Clickable accessors

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

#### Settable accessors

For each settable element, accessor method is defined which sets value to that element.

Click accessor method name is `#{element_name}=`.

Default settable methods are: `[:text_field, :file_field, :textarea, :checkbox]`.

You can make other elements settable by adding tag names to `Watirsome.settable`.

```ruby
# make input settable
Watirsome.settable << :input

class Page
  include Watirsome

  text_field :username, label: 'Username'
  input :date, type: 'date'
end

page = Page.new(@browser)
page.username = 'Username'         # sets value of username text field
page.date = '2013-01-01', :return  # sends text to element and hits "Enter"
```

If found element responds to `#set`, accessor calls it. Otherwise, `#send_keys` is used.

#### Selectable accessors

For each selectable element, accessor method is defined which selects opton of that element.

Click accessor method name is `#{element_name}=`.

Default selectable methods are: `[:select_list]`.

You can make other elements selectable by adding tag names to `Watirsome.selectable`. Though, why would you want?

```ruby
class Page
  include Watirsome

  select_list :country, label: 'Country'
end

page = Page.new(@browser)
page.country = 'Russia'  #=> selects option with "Russia" text
```

### Initializers

Watirsome provides you with initializers DSL to dynamically modify your pages/regions behavior. 

#### Page initializer

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

#### Region initializer

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

Regions are being cached, so, once initialzed, they won't be executed if you call `Page#initialize_regions` again.

Each module is first checked if its name matches the regular expression of region (to make sure we don't touch unrelated included modules). By default, regexp is `/^.+(Region)$/`, but you can change it by altering `Watirsome.region_matcher`.

```ruby
Watirsome.region_matcher = /^.+(Region|Helper)$/
```

### Limitations

1. Currently tested to work only with `watir-webdriver`. Let me know if it works using `watir-classic`.
2. You cannot use `Watir::Browser#select` method as it's overriden by `Kernel#select`. Use `Watir::Browser#select_list` instead.
3. You cannot use block arguments to locate elements for settable/selectable accessors (it makes no sense). However, you can use block arguments for all other accessors.

### Contribute

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright (c) 2013 Alex Rodionov. See LICENSE.md for details.
