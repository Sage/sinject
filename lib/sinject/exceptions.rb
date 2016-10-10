module Sinject
  class DependencyContractMissingMethodsException < StandardError
    def initialize(methods)
      @methods = methods
    end

    def to_s
      method_names = @methods.join(', ')
      "The following methods have not been implemented: '#{method_names}'" if method_names
    end
  end

  class DependencyContractInvalidParametersException < StandardError
    def initialize(method, parameters)
      @method = method
      @parameters = parameters
    end

    def to_s
      parameter_names = @parameters.join(', ')
      "The method signature of method: '#{@method}' does not match the contract parameters: '#{parameter_names}'" if @method && parameter_names
    end
  end

  class DependencyInitializeException < StandardError

    def initialize(expected_type)
      @expected_type = expected_type
    end

    def to_s
      "The custom dependency initializer does not return an object of the expected type: '#{@expected_type}'" if @expected_type
    end

  end

  class DependencyRegistrationException < StandardError

    def initialize(key)
      @key = key
    end

    def to_s
      "A Dependency has already been registered for the key: '#{@key}'" if @key
    end

  end

  class DependencyRegistrationKeyNotSpecifiedException < StandardError

    def to_s
      "A key must be specified to register a dependency."
    end

  end

  class DependencyRegistrationClassNotSpecifiedException < StandardError

    def to_s
      "A dependency class must be specified to register a dependency."
    end

  end
end
