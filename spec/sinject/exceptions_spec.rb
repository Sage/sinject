require 'spec_helper'
require_relative '../../lib/sinject/exceptions'

RSpec.describe Sinject::DependencyRegistrationException do

  let(:key) { 'foo' }

  subject { described_class.new(key) }

  describe '#to_s' do
    specify do
      expect(subject.to_s).to eql %{A Dependency has already been registered for the key: '#{key}'}
    end
  end
end
