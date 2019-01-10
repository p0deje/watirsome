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

### Usage

Watirsome is a pure dynamic Watir-based page object DSL.
Includers can use accessors, initializers and regions APIs.

Accessors DSL allows to isolate elements from your methods.
All accessors are just proxied to Watir, thus you free to use all its power in
your page objects:

 * any method defined in Watir::Container is accessible
 * you can use any kind of locators you use with Watir

#### Element accessors

For each element, accessor method is defined which returns instance of `Watir::Element`
(or subtype when applicable). Element accessor method name is `#{element_name}_#{tag_name}`.

```ruby
class Page
include Watirsome

  element :body, tag_name: 'body'
  div :container, class: 'container'
end

page = Page.new(@browser)
page.body_element  #=> @browser.element(tag_name: 'body')
page.container_div #=> @browser.div(class: 'container')
```

##### readable elements

For each readable element, accessor method is defined which returns text of that element.
Read accessor method name is `element_name`.

Default readable methods are:

```
  [:div, :span, :p, :h1, :h2, :h3, :h4, :h5, :h6, :select_list, :text_field, :textarea, :checkbox, :radio]
```

You can make other elements readable by adding tag names to `Watirsome.readable`.

```ruby
class Page
  include Watirsome

  div :container, class: 'container'
  radio :sex_male, value: 'Male'
end

page = Page.new(@browser)
page.container #=> "Container"
page.sex_male_radio.set
page.sex_male #=> true
```

##### clickable elements

For each clickable element, accessor method is defined which performs click on that element.
Click accessor method name is `element_name`.
Default clickable methods are: `[:a, :link, :button]`.
You can make other elements clickable by adding tag names to `Watirsome.clickable`.

```ruby
class Page
  include Watirsome

  a :open_google, text: 'Open Google'
end

page = Page.new(@browser)
page.open_google
@browser.title #=> "Google"
```

##### settable elements

For each settable element, accessor method is defined which sets value to that element.
Click accessor method name is `#{element_name}=`.
Default settable methods are: `[:text_field, :file_field, :textarea, :checkbox, :select_list]`.
You can make other elements settable by adding tag names to `Watirsome.settable`.

```ruby
class Page
  include Watirsome

  text_field :name, placeholder: 'Enter your name'
  select_list :country, name: 'Country'
  checkbox :agree, name: 'I Agree'
end

page = Page.new(@browser)
page.name = "My name"
page.name #=> "My name"
page.country = "Russia"
page.country #=> "Russia"
page.agree = true
page.agree #=> true
```

#### Custom locators

Watirsome also provides you with opportunity to locate elements by using any
boolean method Watir element (and subelements) supports. See "Custom locators"
example.

```ruby
class Page
  include Watirsome

  div :visible, class: 'visibility', present: true
  div :invisible, class: 'visibility', present: false
  select_list :country, selected: 'USA'
end

page = Page.new(@browser)
page.visible_div.present?   #=> true
page.invisible_div.present? #=> false
page.country_select_list.selected?('USA') #=> true
```

#### Initializers

Watirsome provides you with initializers API to dynamically modify your pages/regions behavior.

Each page may define `#initialize_page` method which will be used as page constructor.

```ruby
class Page
  include Watirsome

  attr_accessor :page_loaded

  def initialize_page
    self.page_loaded = true
  end
end

page = Page.new(@browser)
page.page_loaded
#=> true
```

Each region you include via `has_one` may define `#initialize_region` method which will
be called after page constructor.  Regions are being cached, so, once initialized,
they won't be executed if you call `Page#initialize_regions` again.

```ruby
class ProfileRegion
  include Watirsome

  attr_reader :page_loaded

  def initialize_region
    @page_loaded = true
  end
end

class Page
  include Watirsome

  has_one :profile
end

page = Page.new(@browser)
page.profile.page_loaded
#=> true
```

Before the introduction of `has_one` macro regions could be declared by the inclusion
of ruby modules. This approach still works, but it's deprecated if favor of `has_one`.

```ruby
module HeaderRegion
  def initialize_region
    self.page_loaded = true
  end
end

class Page
  include Watirsome
  include HeaderRegion # DEPRECATED! use has_one instead

  attr_accessor :page_loaded
end

page = Page.new(@browser)
page.page_loaded
#=> true
```

#### Regions

Regions represent parts of DOM tree, that can be either reused on different pages,
or even inside another regions (nested).

There are multiple ways of declaring how regions can be embedded inside their parents.

##### default class

If given page `has_one :profile`, then (by default) class name for this region should be `ProfileRegion`.

```ruby
class ProfileRegion
  include Watirsome

  element :wrapper, class: 'for-profile'
  div :name, -> { wrapper_element.div(class: 'name') }
end

class Page
  include Watirsome

  has_one :profile
end

page = Page.new(@browser)
page.profile.name #=> 'John Smith'
```

##### custom class

Region class can also provided as a parameter to `has_one` declaration.

```ruby
class ProfileDetails
  include Watirsome

  element :wrapper, class: 'for-profile'
  div :name, -> { wrapper_element.div(class: 'name') }
end

class Page
  include Watirsome

  has_one :profile, class: ProfileDetails
end

page = Page.new(@browser)
page.profile.name #=> 'John Smith'
```

##### declaring region within given DOM element

By default region is located anywhere inside its parent (usually page `//body`).
This would make using the same region multiple times on the same page virtually impossible.
To overcome this limitation `has_one` accepts `in` (aka `within`) parameter,
that provides the context element for the region in the DOM tree.

This element can be located using a watir locator hash or a lambda, and is then
available inside the region object using `region_element` method.

```ruby
class ProfileDetails
  include Watirsome
  div :name, class: 'name'
end

class Page
  include Watirsome

  has_one :seller_profile, class: ProfileDetails, in: {id: 'seller'}
  has_one :buyer_profile, class: ProfileDetails, in: -> { region_element.div(id: 'buyer') }
end

page = Page.new(@browser)
page.seller_profile.name #=> 'John Smith'
page.buyer_profile.name  #=> 'Alice Norton'
```

##### inline region

Smaller regions, that are not intended to be reused can be declared without a separate class.
Their elements can be declared inline, inside a block passed to `has_one` macro.

```ruby
class Page
  include Watirsome

  has_one :profile do
    element :wrapper, class: 'for-profile'
    div :name, -> { wrapper_element.div(class: 'name') }
  end
end

page = Page.new(@browser)
page.profile.name #=> 'John Smith'
```

##### Region collection, default class

Collections of elements can be declared using `has_many` macro.
`each` parameter is a locator of a Watir element collection, that define the location
of individual regions from the region collection.

Region class can be provided as another parameter. If it's omitted it defaults to
the same "formula" as in `has_one`: `has_many :users` implies that `UserRegion` class is expected.

```ruby
class UserRegion
  include Watirsome

  div :name, -> { region_element.div(class: 'name') }
end

class Page
  include Watirsome

  has_many :users, each: {class: 'for-user'}
end

page = Page.new(@browser)

# You can use collection region as an array.
page.users.size        #=> 2
page.users.map(&:name) #=> ['John Smith 1', 'John Smith 2']

# You can search for particular regions in collection.
page.user(name: 'John Smith 1').name #=> 'John Smith 1'
page.user(name: 'John Smith 2').name #=> 'John Smith 2'
page.user(name: 'John Smith 3')      #=> raise RuntimeError, "No user matching: #{{name: 'John Smith 3'}}."
```

##### inline region class for a collection

`has_many` accepts a block with a declaration of elements for the region in collection.

```ruby
class Page
  include Watirsome

  has_many :users, each: {class: 'for-user'} do
    div :name, -> { region_element.div(class: 'name') }
  end
end

page = Page.new(@browser)

# You can use collection region as an array.
page.users.size        #=> 2
page.users.map(&:name) #=> ['John Smith 1', 'John Smith 2']
```

##### declaring region collection within given DOM element locator

`has_many` supports `in` parameter is the same way as `has_one`

```ruby
class UserRegion
  include Watirsome

  div :name, -> { region_element.div(class: 'name') }
end

class Page
  include Watirsome

  has_many :users, in: {class: 'for-users'}, each: {class: ['for-user']}
end

page = Page.new(@browser)
page.users.map(&:name) #=> ['John Smith 1', 'John Smith 2']
```

##### declaring region collection within given Watir element

```ruby
class UserRegion
  include Watirsome

  div :name, -> { region_element.div(class: 'name') }
end

class Page
  include Watirsome

  div :users, class: 'for-users'
  has_many :users, in: -> { users_div }, each: {class: ['for-user']}
end

page = Page.new(@browser)
page.users.map(&:name) #=> ['John Smith 1', 'John Smith 2']
```

##### custom collection class (default class)

Additional behavior to the default collection Enumerable can be achieved by
implementing a wrapper class for it. The default name for this class is interpolated
from the collection name: `has_many :users` implies that the region collection class
name is `UsersRegion`.

```ruby
class UserRegion
  include Watirsome

  div :name, -> { region_element.div(class: 'name') }
end

class UsersRegion
  include Watirsome

  def two?
    region_collection.size == 2
  end
end

class Page
  include Watirsome

  has_many :users, each: {class: 'for-user'}
end

page = Page.new(@browser)

# You can use collection region both as its instance and enumerable.
page.users.two?        #=> true
page.users.map(&:name) #=> ['John Smith 1', 'John Smith 2']

# You can access parent collection region from children too.
page.user(name: 'John Smith 1').parent.two? #=> true
```

##### custom collection classes

`has_many` macro allows for customization of both individual region, and region collection classes.
This is achieved using parameters `class` (aka `region_class`) and `through` (aka `collection_class`).

```ruby
class UserDetails
  include Watirsome

  div :name, -> { region_element.div(class: 'name') }
end

class UsersTable
  include Watirsome

  def two?
    region_collection.size == 2
  end
end

class Page
  include Watirsome

  has_many :users, each: {class: 'for-user'}, class: UserDetails, through: UsersTable
end

page = Page.new(@browser)

# You can use collection region both as its instance and enumerable.
page.users.two?        #=> true
page.users.map(&:name) #=> ['John Smith 1', 'John Smith 2']
```

##### instatiating region collection manually

Region collection can be instantiated manually. The constructor has the following synopsis:

```ruby
def initialize(
  browser,  # reference to Watir::Browser
  parent,   # parent Watir::Element
  nodes     # collection of Watir::Elements associated with the region instances
)
```

example:

```ruby
class UserRegion
  include Watirsome

  div :name, -> { region_element.div(class: 'name') }
end

class UsersRegion
  include Watirsome

  def first_half
    self.class.new(@browser, region_element, region_collection.each_slice(1).to_a[0])
  end

  def second_half
    self.class.new(@browser, region_element, @browser.divs(class: 'for-user').each_slice(1).to_a[1])
  end
end

class Page
  include Watirsome

  has_many :users, each: {class: 'for-user'}
end

page = Page.new(@browser)
page.users.first_half.map(&:name)  #=> ['John Smith 1']
page.users.second_half.map(&:name) #=> ['John Smith 2']
```

##### nesting

Regions can be nested inside other regions using either `has_one` or `has_many` macro.

```ruby
class BuyerDetails
  include Watirsome
  div :name, class: 'buyer-name'
end

class Invoice
  include Watirsome
  has_one :buyer, in: { class: 'buyer-wrapper' }
end

class Page
  include Watirsome
  has_many :invoices, class: Invoice, each: { class: 'invoice-wrapper' }
end

page = Page.new(@browser)
page.invoices[0].buyer.name  #=> ['John Smith']
```

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
