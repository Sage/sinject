# frozen_string_literal: true

require 'spec_helper'
require 'sinject/dependency_group'

RSpec.describe Sinject::DependencyGroup do
  describe '#register' do
    it 'returns nil' do
      expect(subject.register('anything')).to be nil
    end
  end

  describe '.descendants' do
    # Testing this method is awkward because it trawls ObjectSpace for
    # DependencyGroup's own subclasses.
    #
    # To clean up after each test we therefore need to remove the
    # definitions of any test DependencyGroup classes we've defined.
    #
    # The tests themselves need to be crafted carefully to ensure that
    # Ruby retains any references to the test classes for the shortest
    # possible time, as any remaining reference will prevent the class
    # from being garbage collected.
    #
    # Test classes should be anonymous to support this. A class name
    # is a constant reference to the class, preventing garbage
    # collection unless the constant is redefined or undefined first
    # (and maybe not even then!).

    # Call the GC after each example to try to clean up the
    # definitions of the test classes.
    #
    # In some circumstances, something may hold a reference to a test
    # class long enough to save it from the garbage collector in the
    # after block. Force the GC both before and after to be sure.
    before { ObjectSpace.garbage_collect }
    after { ObjectSpace.garbage_collect }
    # A final GC call, as if to say that we really mean it!
    after(:all) { ObjectSpace.garbage_collect }

    context 'when no subclasses have been declared' do
      it 'returns an empty collection' do
        expect(described_class.descendants).to eq([])
      end
    end

    context 'when subclasses have been declared' do
      it 'returns a list of those subclasses' do
        group_a = Class.new(Sinject::DependencyGroup)
        group_b = Class.new(Sinject::DependencyGroup)

        # Assert on object ids, as asserting on the classes themselves
        # may cause references to them to be retained and escape
        # garbage collection, even though they're anonymous.
        expect(described_class.descendants.map(&:object_id))
          .to match_array([group_a.object_id, group_b.object_id])
      end

      context 'when a subclass has itself been subclassed' do
        it 'returns all of the subclasses' do
          group_a = Class.new(Sinject::DependencyGroup)
          group_b = Class.new(Sinject::DependencyGroup)
          group_a_subclass = Class.new(group_a)

          # Assert on object ids, as asserting on the classes
          # themselves may cause references to them to be retained and
          # escape garbage collection, even though they're anonymous.
          expect(described_class.descendants.map(&:object_id))
            .to match_array([group_a.object_id, group_b.object_id, group_a_subclass.object_id])
        end
      end
    end
  end
end
