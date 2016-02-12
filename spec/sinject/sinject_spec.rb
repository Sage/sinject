

require 'spec_helper'
require_relative 'test_objects/test_classes'
require 'pry'

describe SinjectContainer do

  it 'should populate the class variable instance when created' do

    container = SinjectContainer.new

    expect(container).to eq(SinjectContainer.instance)
  end

  it 'should report a registered dependency when asked' do

    container = SinjectContainer.new
    container.register(:multi_instance, MultiInstance)

    expect(container.is_registered?(:multi_instance)).to eq(true)

  end

  it 'should return a multi instance object correctly' do
    container = SinjectContainer.new
    container.register(:multi_instance, MultiInstance, false)
    obj1 = container.get(:multi_instance)

    expect(obj1).to be_a(MultiInstance)

    obj2 = container.get(:multi_instance)

    expect(obj1).to_not eq(obj2)
  end

  it 'should return a single instance object correctly' do

    container = SinjectContainer.new
    container.register(:single_instance, SingleInstance, true)
    obj1 = container.get(:single_instance)

    expect(obj1).to be_a(SingleInstance)

    obj2 = container.get(:single_instance)

    expect(obj1).to eq(obj2)

  end

  it 'should build a requested object with dependencies' do

    container = SinjectContainer.new
    container.register(:hello_world, HelloWorld, true)
    container.register(:goodbye_world, GoodbyeWorld, false)
    container.register(:object_with_dependencies, ObjectWithDependency, false)

    obj = container.get(:object_with_dependencies)

    expect(obj.hello_world).to be_a(HelloWorld)
    expect(obj.goodbye_world).to be_a(GoodbyeWorld)

    expect(obj.goodbye_world).to eq(obj.goodbye_world)
  end

  it 'should not throw an exception for a dependency registration with a valid contract' do

    container = SinjectContainer.new

    expect { container.register(:logger, CustomLogger, true, LoggerContract) }.not_to raise_error

  end

  it 'should throw a DependencyContractMissingMethodsException for a dependency registration with missing methods from the contract' do

    container = SinjectContainer.new

    expect { container.register(:logger, SingleInstance, true, LoggerContract) }.to raise_error(DependencyContractMissingMethodsException)

  end

  it 'should throw a DependencyContractInvalidParametersException for a dependency registration with invalid method parameters compared to the contract' do

    container = SinjectContainer.new

    expect { container.register(:cache_control, RedisCacheControl, true, CacheControlContract) }.to raise_error(DependencyContractInvalidParametersException)

  end

  it 'should create a dependency from a custom initialize block' do

    container = SinjectContainer.new
    container.register(:hello_world, HelloWorld) do
      instance = HelloWorld.new
      instance.value = 'Custom init'
      instance
    end

    obj = container.get(:hello_world)

    expect(obj.value).to eq('Custom init')

  end

  it 'should throw a DependencyInitializeException for a dependency initializer block that fails to create a dependency of the expected type' do

    container = SinjectContainer.new
    container.register(:hello_world, HelloWorld) do
        GoodbyeWorld.new
    end

    expect { container.get(:hello_world) }.to raise_error(DependencyInitializeException)

  end

  it 'should load dependencies from valid dependencygroups' do

    container = SinjectContainer.new
    container.load_groups

    expect(container.is_registered?(:hello_world)).to eq(true)
    expect(container.is_registered?(:goodbye_world)).to eq(true)

  end

  it 'should not load dependencies from invalid dependencygroups' do

    container = SinjectContainer.new
    container.load_groups

    expect(container.is_registered?(:logger)).to eq(false)

  end

end