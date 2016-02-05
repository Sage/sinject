
# Sinject

Welcome to Sinject! a simple dependency injection framework for ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sinject'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinject

## Usage

**Rails Setup**

If you're using rails then after you've installed the gem you need to create a *'dependencies.rb'* file within the *'/config/initializers'* directory of the rails application.

**Registering dependencies**

Dependency objects need to be registered with the container before use, to do so you need to configure the SinjectContainer from the dependencies.rb file:

    #initialize the container
    container = SinjectContainer.new
    
    #register your dependencies
    container.register(:cache_store, RedisCacheStore, true)
    container.register(:country_repository, MySqlCountryRepository, false)
   
Dependencies can be registered with the container in 2 modes:

- Single instance:  	This mode ensures that only 1 instance is created for the registered dependency and that all requests to the container for that dependency return the same instance.
- Multi instance:	This mode ensures that a new instance of the registered dependency is returned for each request received by the container. 

The registration mode can be set by specifying **true** or **false** to the *'single_instance'* argument of the containers register method.

**Assigning dependencies**

To assign a dependency to an object you need to add the dependency attribute to the class and specify the symbol key used to register the dependency with the SinjectContainer:

    class MySqlCountryRepository
	    
	    dependency :cache_store
		
		.....
	end

    class CountryController < ActionController::Base
	
		dependency :country_repository    

		.....
    end

Sinject will then inject the registered dependency to that object and it will be accessible via the dependency key:

    country_controller.country_repository.cache_store
 

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sinject. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

=======
# sinject
A simple dependency injection framework for ruby.
>>>>>>> 6a85e4cbf29c3874701332710a37936cff9e7105
