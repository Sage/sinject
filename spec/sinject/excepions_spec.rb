# -*- encoding : utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'
require 'sinject/exceptions'

RSpec.describe Sinject::DependencyContractMissingMethodsException do
  describe '#to_s' do
    it 'returns a message listing all the methods provided on instantiation' do
      error = described_class.new([:fi, :fi, :fo, :fum])
      expect(error.to_s).to eq 'The following methods have not been implemented: '\
                               '\'fi, fi, fo, fum\''
    end
  end
end

RSpec.describe Sinject::DependencyContractInvalidParametersException do
  describe '#to_s' do
    it 'returns a message listing the method and all of the parameters provided on instantiation' do
      error = described_class.new(:bellow, [:fi, :fi, :fo, :fum])
      expect(error.to_s).to eq 'The method signature of method: \'bellow\' does not match the '\
                               'contract parameters: \'fi, fi, fo, fum\''
    end
  end
end

RSpec.describe Sinject::DependencyInitializeException do
  describe '#to_s' do
    it 'returns a message including the type name provided on instantiation' do
      error = described_class.new('TheWrongTrousers')
      expect(error.to_s).to eq 'The custom dependency initializer does not return an object '\
                               'of the expected type: \'TheWrongTrousers\''
    end
  end
end

RSpec.describe Sinject::DependencyRegistrationException do
  describe '#to_s' do
    it 'returns a message including the key provided on instantiation' do
      error = described_class.new(:déjà_vu)
      expect(error.to_s).to eq 'A Dependency has already been registered for the key: \'déjà_vu\''
    end
  end
end

RSpec.describe Sinject::DependencyRegistrationKeyNotSpecifiedException do
  describe '#to_s' do
    it 'returns a constant message' do
      expect(described_class.new.to_s).to eq 'A key must be specified to register a dependency.'
    end
  end
end

RSpec.describe Sinject::DependencyRegistrationClassNotSpecifiedException do
  describe '#to_s' do
    it 'returns a constant message' do
      expect(described_class.new.to_s).to eq 'A dependency class must be specified to register a dependency.'
    end
  end
end
