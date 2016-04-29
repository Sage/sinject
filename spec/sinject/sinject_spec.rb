require 'spec_helper'
require_relative 'test_objects/test_classes'

describe Sinject::Container do

  it 'should populate the class variable instance when created' do

    container = Sinject::Container.new

    expect(container).to eq(Sinject::Container.instance)
  end

  it 'should report a registered dependency when asked' do

    container = Sinject::Container.new
    container.register({ :key => :multi_instance, :class => MultiInstance })

    expect(container.is_registered?(:multi_instance)).to eq(true)

  end

  it 'should return a multi instance object correctly' do
    container = Sinject::Container.new
    container.register({ :key => :multi_instance, :class => MultiInstance, :singleton => false })
    obj1 = container.get(:multi_instance)

    expect(obj1).to be_a(MultiInstance)

    obj2 = container.get(:multi_instance)

    expect(obj1).to_not eq(obj2)
  end

  it 'should return a single instance object correctly' do

    container = Sinject::Container.new
    container.register({ :key => :single_instance, :class => SingleInstance, :singleton => true })
    obj1 = container.get(:single_instance)

    expect(obj1).to be_a(SingleInstance)

    obj2 = container.get(:single_instance)

    expect(obj1).to eq(obj2)

  end

  it 'should build a requested object with dependencies' do

    container = Sinject::Container.new
    container.register({ :key => :hello_world, :class => HelloWorld, :singleton => true })
    container.register({ :key => :goodbye_world, :class => GoodbyeWorld, :singleton => false })
    container.register({ :key => :object_with_dependencies, :class => ObjectWithDependency, :singleton => false })

    obj = container.get(:object_with_dependencies)

    expect(obj.hello_world).to be_a(HelloWorld)
    expect(obj.goodbye_world).to be_a(GoodbyeWorld)

    expect(obj.goodbye_world).to eq(obj.goodbye_world)
  end

  it 'should not throw an exception for a dependency registration with a valid contract' do

    container = Sinject::Container.new

    expect { container.register({ :key => :logger, :class => CustomLogger, :singleton => true, :contract => LoggerContract }) }.not_to raise_error

  end

  it 'should throw a DependencyContractMissingMethodsException for a dependency registration with missing methods from the contract' do

    container = Sinject::Container.new

    expect { container.register({ :key => :logger, :class => SingleInstance, :singleton => true, :contract => LoggerContract }) }.to raise_error(Sinject::DependencyContractMissingMethodsException)

  end

  it 'should throw a DependencyContractInvalidParametersException for a dependency registration with invalid method parameters compared to the contract' do

    container = Sinject::Container.new

    expect { container.register({ :key => :cache_control, :class => RedisCacheControl, :singleton => true, :contract => CacheControlContract }) }.to raise_error(Sinject::DependencyContractInvalidParametersException)

  end

  it 'should create a dependency from a custom initialize block' do

    container = Sinject::Container.new
    container.register({ :key => :hello_world, :class => HelloWorld }) do
      instance = HelloWorld.new
      instance.value = 'Custom init'
      instance
    end

    obj = container.get(:hello_world)

    expect(obj.value).to eq('Custom init')

  end

  it 'should throw a DependencyInitializeException for a dependency initializer block that fails to create a dependency of the expected type' do

    container = Sinject::Container.new
    container.register({ :key => :hello_world, :class => HelloWorld }) do
        GoodbyeWorld.new
    end

    expect { container.get(:hello_world) }.to raise_error(Sinject::DependencyInitializeException)

  end

  it 'should load dependencies from valid dependencygroups' do

    container = Sinject::Container.new
    container.load_groups

    expect(container.is_registered?(:hello_world)).to eq(true)
    expect(container.is_registered?(:goodbye_world)).to eq(true)

  end

  it 'should not load dependencies from invalid dependencygroups' do

    container = Sinject::Container.new
    container.load_groups

    expect(container.is_registered?(:logger)).to eq(false)

  end

end