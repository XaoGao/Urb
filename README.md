# Urb

Simple gem for dynamicly and fast create a url.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'urb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install urb

## Usage

    $  require 'iri'
    url = Urb::Builder.new('http://example.com')
            .append('users').append(:Joy) # add path fragment -> http://example.com/users/joy
            .cut('joy) # remove fragment form path-> http://example.com/users
            .add(search: 'fiends', id: 'current_user) # add queries params-> http://example.com/users?search=friends&id=current_user
            .del(:id) # remove queries params-> http://example.com/users?search=friends
            .over(search: 'family') # override queries params-> http://example.com/users?search=family
            .scheme('https') # override scheme -> https://example.com/users?search=family
            .host('my-websity.com') # override host -> https://my-websity.com/users?search=family
            .port('3001') # override port -> https://my-websity.com:3001/users?search=family
            .to_url # build result

### Support methods:

* **append(string)**: <br/>
  Add a new segment to Url. Argument for methods must be string or symbol. Alias for method: **path** or **fragment**.

* **cut(string)**: <br/>
    Delete a segment from Url. Argument for methods must be string or symbol.

* **add(hash)**: <br/>
    Add a params to query. Argument for methods must be hash. Alias for method: **query**.

* **del(sym)**: <br/>
    Delete a param from query. Argument for methods must symbol. Alias for method: **delete**.

* **over(hash)**: <br/>
    Override params from query. Argument for methods must hash. 

* **scheme(sym)**: <br/>
    Override a scheme. Argument for methods must string or symbol.

* **host(sym)**: <br/>
    Override a host. Argument for methods must string.

* **port(sym)**: <br/>
    Override a port. Argument for methods must string.

* **to_s**: <br/>
    Build a url. Retrun a url as string. Alias for method: **build_as_string**.

* **to_url(sym)**: <br/>
    Build a url. Retrun a url as URI. Alias for method: **build_as_url**.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/urb.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
