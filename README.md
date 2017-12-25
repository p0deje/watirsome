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

See documentation [examples](http://www.rubydoc.info/gems/watirsome/Watirsome)
for API usage.

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
