# frozen_string_literal: true

require 'spec_helper'
require 'singleton'

require 'sinject/container'
require 'sinject/container_item'
require 'sinject/exceptions'
require 'sinject/dependency_group'

RSpec.describe Sinject::Container do
  describe '.new' do
    before { @original_container = Sinject::Container.instance }
    after { Sinject::Container.instance = @original_container }

    context 'when the singleton parameter is not specified' do
      it 'populates the class variable instance' do
        container = Sinject::Container.new
        expect(Sinject::Container.instance).to be container
      end
    end

    context 'when the singleton parameter is true' do
      it 'populates the class variable instance' do
        container = Sinject::Container.new(true)
        expect(Sinject::Container.instance).to be container
      end
    end

    context 'when the singleton parameter is false' do
      it 'does not populate the class variable instance' do
        container = Sinject::Container.new(false)
        expect(Sinject::Container.instance).not_to be container
      end
    end
  end

  subject(:container) { described_class.new(false) }

  describe '#register' do
    context 'when the key is not specified' do
      it 'raises DependencyRegistrationKeyNotSpecifiedException' do
        expect { container.register(class: Object) }
          .to raise_error Sinject::DependencyRegistrationKeyNotSpecifiedException
      end
    end

    context 'when the key is nil' do
      it 'raises an error' do
        pending('Bug: This should really fail if key is truly a required argument')

        expect { container.register(key: nil, class: String) }
          .to raise_error # Error TBD
      end
    end

    context 'when the class is not specified' do
      it 'raises DependencyRegistrationClassNotSpecifiedException' do
        expect { container.register(key: :foo) }
          .to raise_error Sinject::DependencyRegistrationClassNotSpecifiedException
      end
    end

    context 'when the class is nil' do
      it 'raises an error' do
        pending('Bug: This should really fail if class is truly a required argument')

        expect { container.register(key: :foo, class: nil) }
          .to raise_error # Error TBD
      end
    end

    context 'when called more than once with the same key' do
      it 'raises DependencyRegistrationException on the second call' do
        container.register(key: :foo, class: Object)
        expect { container.register(key: :foo, class: String) }
          .to raise_error Sinject::DependencyRegistrationException
      end
    end

    context 'when both key and class are provided' do
      it 'registers the dependency' do
        container.register(key: :foo, class: String)
        expect(container.registered?(:foo)).to be_truthy
      end
    end

    context 'when singleton is specified' do
      it 'registers the dependency' do
        container.register(key: :foo, class: String, singleton: true)
        expect(container.registered?(:foo)).to be_truthy
      end
    end

    context 'when a contract class is provided' do
      let(:contract) do
        Class.new do
          def no_args; end
          def with_args(first, second, third = true, fourth:, fifth:, sixth: true); end
        end
      end

      context 'and the class matches the contract class' do
        it 'registers the dependency' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third = true, fourth:, fifth:, sixth: true); end
          end

          container.register(key: :foo, class: klass, contract: contract)
          expect(container.registered?(:foo)).to be_truthy
        end

        context 'and implements additional methods' do
          it 'registers the dependency' do
            klass = Class.new do
              def no_args; end
              def with_args(first, second, third = true, fourth:, fifth:, sixth: true); end
              def another_method; end
            end

            container.register(key: :foo, class: klass, contract: contract)
            expect(container.registered?(:foo)).to be_truthy
          end
        end
      end

      context 'and the class does not implement every contract method' do
        it 'raises DependencyContractMissingMethodsException' do
          klass = Class.new do
            def no_args; end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractMissingMethodsException
        end
      end

      context 'and a method of the class does not accept a parameter in the contract' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args; end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and a method of the class accepts more than the contract parameters' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third = true, fourth:, fifth:, sixth: true, too_many: true); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and the names of the parameters of a method of the class '\
              'do not match those in the contract' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args(one, two, three = true, four:, five:, six: true); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and the names of the positional parameters of a method of the class '\
              'match those of the contract but in a different order' do
        it 'raises an error' do
          pending('Bug: Arguments in the wrong order should not satisfy a contract')

          klass = Class.new do
            def no_args; end
            def with_args(second, first, third = true, fourth:, fifth:, sixth: true); end
            def with_kw_args(first, second:, third: true); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error # Error TBD
        end
      end

      context 'and a positional parameter in the contract is replaced by a keyword parameter in the class' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third: true, fourth:, fifth:, sixth: true); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and a keyword parameter in the contract is replaced by a positional parameter in the class' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third = true, fourth, fifth:, sixth: true); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and an optional positional parameter in the contract is made required in the class' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third, fourth:, fifth:, sixth: true); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and an optional keyword parameter in the contract is made required in the class' do
        it 'raises DependencyContractInvalidParametersException' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third = true, fourth:, fifth:, sixth:); end
          end

          expect { container.register(key: :foo, class: klass, contract: contract) }
            .to raise_error Sinject::DependencyContractInvalidParametersException
        end
      end

      context 'and a required keyword parameter in a contract method is made optional in the class' do
        it 'registers the dependency' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second, third = true, fourth:, fifth: false, sixth: true); end
          end

          container.register(key: :foo, class: klass, contract: contract)
          expect(container.registered?(:foo)).to be_truthy
        end
      end

      context 'and a required positional parameter in the contract is made optional in the class' do
        it 'registers the dependency' do
          klass = Class.new do
            def no_args; end
            def with_args(first, second = false, third = true, fourth:, fifth:, sixth: true); end
          end

          container.register(key: :foo, class: klass, contract: contract)
          expect(container.registered?(:foo)).to be_truthy
        end
      end

      context 'that specifies rest parameters' do
        let(:contract) do
          Class.new do
            def with_rest_args(first, second, *args); end
          end
        end

        context 'and the class does not specify them' do
          it 'raises DependencyContractInvalidParametersException' do
            klass = Class.new do
              def with_rest_args(first, second); end
            end

            expect { container.register(key: :foo, class: klass, contract: contract) }
              .to raise_error Sinject::DependencyContractInvalidParametersException
          end
        end

        context 'and the class specifies an additional parameter' do
          it 'raises DependencyContractInvalidParametersException' do
            klass = Class.new do
              def with_rest_args(first, second, args); end
            end

            expect { container.register(key: :foo, class: klass, contract: contract) }
              .to raise_error Sinject::DependencyContractInvalidParametersException
          end
        end

        context 'and the class specifies the rest arguments' do
          it 'registers the dependency' do
            klass = Class.new do
              def with_rest_args(first, second, *args); end
            end

            container.register(key: :foo, class: klass, contract: contract)
            expect(container.registered?(:foo)).to be_truthy
          end
        end
      end

      context 'that specifies keyrest parameters' do
        let(:contract) do
          Class.new do
            def with_kwrest_args(foo, bar:, **kwargs); end
          end
        end

        context 'and the class does not specify them' do
          it 'raises DependencyContractInvalidParametersException' do
            klass = Class.new do
              def with_kwrest_args(foo, bar:); end
            end

            expect { container.register(key: :foo, class: klass, contract: contract) }
              .to raise_error Sinject::DependencyContractInvalidParametersException
          end
        end

        context 'and the class specifies a required keyword param of the same name' do
          it 'raises DependencyContractInvalidParametersException' do
            klass = Class.new do
              def with_kwrest_args(foo, bar:, kwargs:); end
            end

            expect { container.register(key: :foo, class: klass, contract: contract) }
              .to raise_error Sinject::DependencyContractInvalidParametersException
          end
        end

        context 'and the class specifies an optional keyword param of the same name' do
          it 'raises DependencyContractInvalidParametersException' do
            klass = Class.new do
              def with_kwrest_args(foo, bar:, kwargs: nil); end
            end

            expect { container.register(key: :foo, class: klass, contract: contract) }
              .to raise_error Sinject::DependencyContractInvalidParametersException
          end
        end

        context 'and the class specifies them' do
          it 'registers the dependency' do
            klass = Class.new do
              def with_kwrest_args(foo, bar:, **kwargs); end
            end

            container.register(key: :foo, class: klass, contract: contract)
            expect(container.registered?(:foo)).to be_truthy
          end
        end
      end

      context 'when the contract expects a block' do
        let(:contract) do
          Class.new do
            def with_block(foo, &block); end
          end
        end

        context 'and the class does not' do
          it 'raises DependencyContractInvalidParametersException' do
            klass = Class.new do
              def with_block(foo); end
            end

            expect { container.register(key: :foo, class: klass, contract: contract) }
              .to raise_error Sinject::DependencyContractInvalidParametersException
          end
        end

        context 'and the class does too' do
          it 'registers the dependency' do
            klass = Class.new do
              def with_block(foo, &block); end
            end

            container.register(key: :foo, class: klass, contract: contract)
            expect(container.registered?(:foo)).to be_truthy
          end
        end
      end
    end
  end

  describe '#get' do
    context 'when the requested dependency has been registered' do
      it 'returns and instance of the dependency' do
        container.register(key: :foo, class: String)
        expect(container.get(:foo)).to be_an_instance_of(String)
      end

      context 'as a singleton' do
        context 'and is requested multiple times consecutively' do
          it 'returns the same instance each time' do
            container.register(key: :foo, class: String, singleton: true)
            first = container.get(:foo)
            second = container.get(:foo)
            expect(first).to be second
          end
        end

        context 'and is requested multiple times concurrently' do
          it 'returns the same instance each time' do
            pending('Bug: There are no critical sections in #get so race conditions are possible')

            # This test is a bit problematic. It's ultimately
            # non-deterministic, though it's likely a reasonably safe
            # assumption that the system can spawn at least two
            # threads within one second.
            container.register(key: :foo, class: Array, singleton: true) do
              sleep(1)
              []
            end

            instances = Set.new.compare_by_identity
            mutex = Mutex.new
            threads = 2.times.map do
              Thread.new do
                inst = container.get(:foo)
                mutex.synchronize { instances.add(inst) }
              end
            end
            threads.each(&:join)

            expect(instances.size).to eq 1
          end
        end
      end

      context 'as multi-instance' do
        it 'returns a new instance each time' do
          container.register(key: :foo, class: String, singleton: false)
          first = container.get(:foo)
          second = container.get(:foo)
          expect(first).not_to be second
        end
      end

      context 'without an initializer block but with a type that requires arguments to .new' do
        it 'raises ArgumentError' do
          klass = Class.new do
            def initialize(an_arg); end
          end

          container.register(key: :foo, class: klass)
          expect { container.get(:foo) }.to raise_error ArgumentError
        end
      end

      context 'with an initializer block' do
        it 'returns the object returned by the block' do
          expected = 'codfanglers'
          container.register(key: :foo, class: String) { expected }
          expect(container.get(:foo)).to be expected
        end

        context 'but the block does not return the registered type' do
          it 'raises DependencyInitializeException' do
            container.register(key: :foo, class: Hash) { [] }
            expect { container.get(:foo) }.to raise_error Sinject::DependencyInitializeException
          end
        end
      end
    end

    context 'when the requested dependency has not been registered' do
      context 'but its name can be parlayed into the name of an existing type' do
        context 'that can be instantiated without arguments' do
          it 'returns an instance of that type' do
            expect(container.get(:array)).to be_an_instance_of(Array)
          end
        end

        context 'that cannot be instantiated without arguments' do
          it 'raises ArgumentError' do
            expect { container.get(:range) }.to raise_error ArgumentError
          end
        end

        context 'that cannot be instantiated at all' do
          it 'raises ArgumentError' do
            expect { container.get(:nil_class) }.to raise_error NoMethodError
          end
        end
      end

      context 'whose name can not be parlayed into the name of an existing type' do
        it 'raises NameError' do
          expect { container.get(:if_there_is_a_class_with_this_name_i_will_eat_my_hat) }.to raise_error NameError
        end
      end
    end
  end

  describe '#registered?' do
    before do
      container.register(key: :foo, class: Object)
    end

    context 'when the specified key has been registered' do
      it 'returns a truthy value' do
        expect(container.registered?(:foo)).to be_truthy
      end
    end

    context 'when the specified key has not been registered' do
      it 'returns a falsey value' do
        expect(container.registered?(:bar)).to be_falsey
      end
    end
  end

  describe '#is_registered?' do
    before do
      container.register(key: :foo, class: Object)
    end

    context 'when the specified key has been registered' do
      it 'returns a truthy value' do
        expect(container.is_registered?(:foo)).to be_truthy
      end
    end

    context 'when the specified key has not been registered' do
      it 'returns a falsey value' do
        expect(container.is_registered?(:bar)).to be_falsey
      end
    end
  end

  describe '#load_groups' do
    # We can't just declare real DependencyGroup subclasses for these
    # tests because the DependencyGroup.descendants method trawls
    # ObjectSpace for its own subclasses.
    #
    # Given this, we would need to remove the definitions of any test
    # DependencyGroup classes we defined in the clean-up for each
    # test. It's next to impossible to do this reliably because
    # different Ruby versions will keep references to the classes for
    # different lengths of time, and any remaining reference will
    # prevent the class from being garbage collected.
    #
    # To work around this we must stub DependencyGroup.descendants and
    # none of the test classes can inherit DependencyGroup.
    before { class_double(Sinject::DependencyGroup, descendants: descendants).as_stubbed_const }

    let(:descendants) { [group] }

    context 'when a DependencyGroup has been declared' do
      context 'without a #valid? or #is_valid method' do
        let(:group) do
          Class.new do
            class << self
              attr_accessor :registered
            end

            def register(_container); self.class.registered = true; end
          end
        end

        it 'does not call its #register method' do
          expect(group.registered).to be nil
          container.load_groups
          expect(group.registered).to be nil
        end
      end

      context 'with a #valid? and #is_valid method that both return false' do
        let(:group) do
          Class.new do
            class << self
              attr_accessor :registered
            end

            def valid?; false; end
            def is_valid?; false; end
            def register(_container); self.class.registered = true; end
          end
        end

        it 'does not call its #register method' do
          expect(group.registered).to be nil
          container.load_groups
          expect(group.registered).to be nil
        end
      end

      context 'with both a #valid? and #is_valid method' do
        context 'and #valid? returns true' do
          let(:group) do
            Class.new do
              class << self
                attr_accessor :registered
              end

              def valid?; true; end
              def is_valid?; false; end
              def register(_container); self.class.registered = true; end
            end
          end

          it 'calls its #register method' do
            expect(group.registered).to be nil
            container.load_groups
            expect(group.registered).to be true
          end
        end

        context 'and #is_valid? returns true' do
          let(:group) do
            Class.new do
              class << self
                attr_accessor :registered
              end

              def valid?; false; end
              def is_valid?; true; end
              def register(_container); self.class.registered = true; end
            end
          end

          it 'calls its #register method' do
            expect(group.registered).to be nil
            container.load_groups
            expect(group.registered).to be true
          end
        end
      end
    end

    context 'when a valid DependencyGroup has been declared' do
      let(:group) do
        Class.new do
          class << self
            attr_accessor :received_container
          end

          def valid?; true; end
          def register(container); self.class.received_container = container; end
        end
      end

      it 'passes the container instance to its #register method' do
        expect(group.received_container).to be nil
        container.load_groups
        expect(group.received_container).to be container
      end
    end

    context 'when multiple valid DependencyGroups have been declared' do
      let!(:group_call_order) do
        TestDepGroupCallOrder = Class.new do
          include Singleton

          def callers; @callers ||= []; end
        end
      end

      # These test classes need to be named due to a bug (arguably) in
      # the registration code.
      let(:group_a) do
        # Ensure class has a name
        TestDepGroupCallOrderA = Class.new do
          def valid?; true; end
          def register(_container); TestDepGroupCallOrder.instance.callers << self.class.name; end
        end
      end

      let(:group_b) do
        # Ensure class has a name
        TestDepGroupCallOrderB = Class.new do
          def valid?; true; end
          def register(_container); TestDepGroupCallOrder.instance.callers << self.class.name; end
        end
      end

      let(:descendants) { [group_b, group_a] }

      it 'calls their #register methods in alphabetic order of their class names' do
        container.load_groups
        expect(group_call_order.instance.callers).to eq(['TestDepGroupCallOrderA', 'TestDepGroupCallOrderB'])
      end
    end

    context 'when a DependencyGroup has been declared as an anonymous class' do
      let(:anon_group) do
        Class.new do
          class << self
            attr_accessor :registered
          end

          def valid?; true; end
          def register(_container); self.class.registered = true; end
        end
      end

      context 'and is the only DependencyGroup to have been declared' do
        let(:descendants) { [anon_group] }

        it 'calls its #register method if valid' do
          expect(anon_group.registered).to be nil
          container.load_groups
          expect(anon_group.registered).to be true
        end
      end

      context 'and other DependencyGroups have been declared' do
        let(:descendants) do
          TestNamedDepGroup = Class.new
          [TestNamedDepGroup, anon_group]
        end

        it 'calls its #register method' do
          pending('Bug: Anonymous DependencyGroups cause the attempt to sort classes by name to raise')

          expect(anon_group.registered).to be nil
          container.load_groups
          expect(anon_group.registered).to be true
        end
      end
    end
  end
end
