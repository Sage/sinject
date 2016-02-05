

require 'spec_helper'
require_relative 'test_objects/test_classes'

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

end