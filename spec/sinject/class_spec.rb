# frozen_string_literal: true

require 'spec_helper'
require 'sinject/container_item'
require 'sinject/container'
require 'sinject/class'

describe Class do
  before { @original_container = Sinject::Container.instance }
  after { Sinject::Container.instance = @original_container }

  describe '.dependency' do
    let(:container) { Sinject::Container.new }
    let(:foo) { Class.new }
    let(:bar) { Class.new }

    before do
      container.register(key: :foo, class: foo, singleton: false)
      container.register(key: :bar, class: bar, singleton: false)
    end

    describe 'creates an instance method that' do
      it 'has the name specified' do
        expect(subject.instance_methods).not_to include(:foo, :bar)
        subject.dependency :foo, :bar
        expect(subject.instance_methods).to include(:foo, :bar)
      end

      it 'returns the dependency registered with the same name in the container' do
        subject.dependency :foo, :bar
        instance = subject.new
        expect(instance.foo).to be_an_instance_of(foo)
        expect(instance.bar).to be_an_instance_of(bar)
      end

      it 'returns the same instance each time' do
        subject.dependency :foo
        instance = subject.new
        first = instance.foo
        second = instance.foo
        expect(first).to be second
      end

      it 'returns the same instance each time when called concurrently' do
        pending('The check and set memoization in the generated getter has no critical sections')
        # This test is a bit problematic. It's ultimately
        # non-deterministic, though it's likely a reasonably safe
        # assumption that the system can spawn at least two threads
        # within one second.
        container.register(key: :baz, class: Array, singleton: false) do
          sleep(1)
          []
        end
        subject.dependency :baz
        instance = subject.new

        instances = Set.new.compare_by_identity
        mutex = Mutex.new
        threads = 2.times.map do
          Thread.new do
            inst = instance.baz
            mutex.synchronize { instances.add(inst) }
          end
        end
        threads.each(&:join)

        expect(instances.size).to eq 1
      end
    end
  end
end
