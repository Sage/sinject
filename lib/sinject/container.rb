module Sinject
#This is the IOC Container for registering all dependencies an building objects.
  class Container

    class << self
      attr_accessor :instance
    end

    def initialize(singleton=true)
      @store = {}
      Sinject::Container.instance = self if singleton
    end

    # Check if an object has been registered with the container.
    #
    # Example:
    #   >> Sinject::Container.instance.registered? :object_key
    #   => true
    #
    # Arguments:
    #   key:  (Symbol)
    def registered?(key)
      @store.has_key?(key)
    end
    # @deprecated: Use registered? method instead
    def is_registered?(key)
      puts "[#{self.class}] - #is_registered? method is deprecated please use #registered? instead."
      registered?(key)
    end

    # Register an object with the container.
    # Objects can be registered as either a single instance or a multi instance object.
    # Single instance objects are only initialized once and the same object is returned from the container for every request.
    # Multi instance objects are a new instance that is created for each request.
    #
    # Example:
    #   >> Sinject::Container.instance.register { :key => :object_key, :class => ClassName, :singleton => true, :contract => ContractName }
    #
    # Arguments:
    #   key:  (Symbol)
    #   class_name: (ClassName)
    #   single_instance:  (Boolean)
    def register(options = {}, &initialize_block)
      raise Sinject::DependencyRegistrationKeyNotSpecifiedException.new unless options.has_key?(:key)

      raise Sinject::DependencyRegistrationClassNotSpecifiedException.new unless options.has_key?(:class)

      key = options[:key]
      dependency_class_name = options[:class]

      # check if a dependency has already been registered for this key.
      raise Sinject::DependencyRegistrationException.new(key) if registered?(key)

      single_instance = false
      contract_class_name = nil

      if options != nil && options[:singleton] == true
        single_instance = true
      end

      if options != nil && options[:contract] != nil
        contract_class_name = options[:contract]
      end

      # Validate the dependency class against the contract if a contract has been specified
      validate_contract(dependency_class_name, contract_class_name) unless contract_class_name.nil?

      item = Sinject::ContainerItem.new
      item.key = key
      item.single_instance = single_instance
      item.class_name = dependency_class_name
      item.initialize_block = initialize_block

      @store[item.key] = item
      true
    end

    # Get an object from the container.
    # This will build the requested object and all its dependencies.
    #
    # Example:
    #   >> Sinject::Container.instance.get :object_key
    #
    # Arguments:
    #   key:  (Symbol)
    def get(key)
      # get the dependency from the container store for the specified key
      item = @store[key]
      if !item.nil?
        # check if the item has been registered as a single instance item.
        if item.single_instance == true
          # check if the instance needs to be created
          item.instance = create_instance(item) if item.instance.nil?

          return item.instance
        else
          return create_instance(item)
        end
      else
        # no dependency has been registered for the specified key,
        # attempt to convert the key into a class name and initialize it.
        class_name = "#{key}".split('_').collect(&:capitalize).join
        puts "[#{self.class}] - WARNING: No registered dependency could be found for key: #{key}. " \
"Attempting to load class: #{class_name}."
        Object.const_get(class_name).new
      end
    end

    def load_groups
      Sinject::DependencyGroup.descendants.sort_by(&:name).each do |g|
        group = g.new
        if (group.respond_to?(:valid?) && group.valid?) || (group.respond_to?(:is_valid?) && group.is_valid?)
          group.register(self)
        end
      end
    end

    private

    def validate_contract(dependency_class, contract_class)
      # get the methods defined for the contract
      contract_methods = (contract_class.instance_methods - Object.instance_methods)
      # get the methods defined for the dependency
      dependency_methods = (dependency_class.instance_methods - Object.instance_methods)
      # calculate any methods specified in the contract that are not specified in the dependency
      missing_methods = contract_methods - dependency_methods

      if !missing_methods.empty?
        raise Sinject::DependencyContractMissingMethodsException.new(missing_methods)
      end

      # loop through each contract method
      contract_methods.each do |method|
        # get the contract method parameters
        contract_params = contract_class.instance_method(method).parameters.map{ |p| { type: p[0], name: p[1] } }

        # get the dependency method parameters
        dependency_params = dependency_class.instance_method(method).parameters.map{ |p| { type: p[0], name: p[1] } }

        errors = []

        contract_params.each do |cp|
          dp = dependency_params.detect { |p| p[:name] == cp[:name] }
          if dp.nil? || !match?(cp, dp)
            errors << cp[:name]
          end
        end

        dependency_params.each do |dp|
          cp = contract_params.detect { |p| p[:name] == dp[:name] }
          if cp.nil?
            errors << dp[:name]
          end
        end

        # check if any parameter errors
        if errors.length > 0
          raise Sinject::DependencyContractInvalidParametersException.new(method, errors)
        end
      end
    end

    def match?(contract, dependency)
      return true if contract[:type] == dependency[:type]
      return true if contract[:type] == :req && dependency[:type] == :opt
      return true if contract[:type] == :keyreq && dependency[:type] == :key
      return false
    end

    def create_instance(item)
      # check if a custom initializer block has been specified
      if item.initialize_block != nil
        # call the block to create the dependency instance
        instance = item.initialize_block.call

        # verify the block created the expected dependency type
        raise Sinject::DependencyInitializeException.new(item.class_name) unless instance.is_a?(item.class_name)
      else
        instance = item.class_name.new
      end

      instance
    end
  end
end
