
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

Dependency objects need to be registered with the container before use, to do so you need to configure the SinjectContainer: [If you're using rails this will need to be done within the *'dependencies.rb'* file]

    #initialize the container
    container = SinjectContainer.new
    
    #register your dependencies
    container.register(:cache_store, RedisCacheStore, true)
    container.register(:country_repository, MySqlCountryRepository, false)
   
Dependencies can be registered with the container in 2 modes:

- **Single instance:**  	This mode ensures that only 1 instance is created for the registered dependency and that all requests to the container for that dependency return the same instance.
- **Multi instance:**	This mode ensures that a new instance of the registered dependency is returned for each request received by the container. 

The registration mode can be set by specifying **true** or **false** to the *'single_instance'* argument of the containers register method.

Dependencies that require custom initialization can be registered with an initialization block to handle the creation of the dependency, this allows you more control over how the dependency is created if required:

    container.register(:cache_store, RedisCacheStore, true) do
        instance = RedisCacheStore.new
        instance.host = 'http://localhost'
        instance.port = '6369'
        instance
    end

Dependencies with a custom initialization block must return an object of the registered dependency class type, if an unexpected instance is returned then Sinject will raise a `DependencyInitializeException`.

**Dependency Contracts**

Dependency contracts can be defined to validate registered dependencies are valid for the task they are being registered for. *(If you are familiar with other type based languages then you can think of this as a kind of Interface)*

To create a dependency contract you need to create a new class with empty methods for each of the methods that the dependency needs to respond to in order to fulfill it's role:

    class LoggerContract
        def write(message)
        end
    end

Then when registering a dependency for the role the contract is written for, you can assign the contract:

    #register the dependency
    container.register(:logger, FileLogger, false, LoggerContract)
    
Sinject will then validate that the registered dependency meets the requirements specified within the contract. If a dependency does not meet the contract requirements then 1 of the following exceptions will be raised:

- `DependencyContractMissingMethodsException` is raised when 1 or more methods from the contract could not be found on the dependency.
- `DependencyContractInvalidParametersException` is raised when the parameters of a contract method do not match the parameters found on a dependency method.

**Dependency Groups**

Dependency registration groups can be created to allow groups of dependencies to be set without the need for manual registration *(e.g. to include with a gem for auto registration)*, or to allow different dependency groups to be loaded in different circumstances *(e.g. per environment)*.

To create a dependency group, create a class that inherits from the `DependencyGroup` base class and implement the `register` & `is_valid?` methods.

For example:

    #create a development only dependency group
    class DevelopmentDependencies < DependencyGroup
        def register(container)
            container.register(:cache_store, LocalCacheStore, true)
            container.register(:logger, TerminalLogger, true)
        end
        
        def is_valid?
            Rails.env.development?
        end
    end

To load valid dependency groups the following method needs to be called from the container:

    container.load_groups
    
**Assigning dependencies**

To assign a dependency to an object you need to add the dependency attribute to the class and specify the symbol key that was used to register the dependency with the SinjectContainer:

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

Bug reports and pull requests are welcome on GitHub at https://github.com/vaughanbrittonsage/sinject. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
