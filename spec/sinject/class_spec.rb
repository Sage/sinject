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
      container.register(key: :foo, class: foo)
      container.register(key: :bar, class: bar)
    end

    describe 'creates instance methods that' do
      it 'have the names specified' do
        expect(subject.instance_methods).not_to include(:foo, :bar)
        subject.dependency :foo, :bar
        expect(subject.instance_methods).to include(:foo, :bar)
      end

      it 'return the dependency registered with the same name in the container' do
        subject.dependency :foo, :bar
        instance = subject.new
        expect(instance.foo).to be_an_instance_of(foo)
        expect(instance.bar).to be_an_instance_of(bar)
      end
    end
  end
end
