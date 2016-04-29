module Sinject
#This is the IOC Container for registering all dependencies an building objects.
  class Container

    class << self
      attr_accessor :instance
    end

    def initialize
      @store = []
      Sinject::Container.instance = self
    end

    # Check if an object has been registered with the container.
    #
    # Example:
    #   >> Sinject::Container.instance.is_registered? :object_key
    #   => true
    #
    # Arguments:
    #   key:  (Symbol)
    def is_registered?(key)
      !@store.select { |i| i.key == key}.empty?
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

      if(!options.has_key?(:key))
        raise Sinject::DependencyRegistrationKeyNotSpecifiedException.new
      end

      if(!options.has_key?(:key))
        raise Sinject::DependencyRegistrationClassNotSpecifiedException.new
      end

      key = options[:key]
      dependency_class_name = options[:class]

      #check if a dependency has already been registered for this key.
      if is_registered?(key)
        raise Sinject::DependencyRegistrationException.new(key)
      end

      single_instance = false
      contract_class_name = nil

      if options != nil && options[:singleton] == true
        single_instance = true
      end

      if options != nil && options[:contract] != nil
        contract_class_name = options[:contract]
      end

      #check if a contract has been specified
      if contract_class_name != nil
        #validate the dependency class against the contract
        validate_contract(dependency_class_name, contract_class_name)
      end

      item = Sinject::ContainerItem.new
      item.key = key
      item.single_instance = single_instance
      item.class_name = dependency_class_name
      item.initialize_block = initialize_block

      @store.push(item)
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
      #get the dependency from the container store for the specified key
      items = @store.select { |i| i.key == key}
      if !items.empty?
        item = items.first

        #check if the item has been registered as a single instance item.
        if item.single_instance == true
          #check if the instance needs to be created
          if item.instance == nil
            item.instance = create_instance(item)
          end
          return item.instance
        else
          return create_instance(item)
        end
      else
        #no dependency has been registered for the specified key, attempt to convert the key into a class name and initialize it.
        class_name = "#{key}".split('_').collect(&:capitalize).join
        puts "[Sinject] - WARNING: No registered dependency could be found for key: #{key}. Attempting to load class: #{class_name}."
        Object.const_get(class_name).new
      end
    end

    def load_groups
      Sinject::DependencyGroup.descendants.each do |g|
        group = g.new
        if group.is_valid?
          group.register(Sinject::Container.instance)
        end
      end
    end

    private

    def validate_contract(dependency_class, contract_class)

      #get the methods defined for the contract
      contract_methods = (contract_class.instance_methods - Object.instance_methods)
      #get the methods defined for the dependency
      dependency_methods = (dependency_class.instance_methods - Object.instance_methods)
      #calculate any methods specified in the contract that are not specified in the dependency
      missing_methods = contract_methods - dependency_methods

      if !missing_methods.empty?
        raise Sinject::DependencyContractMissingMethodsException.new(missing_methods)
      end

      #loop through each contract method
      contract_methods.each do |method|

        #get the contract method parameters
        cmp = contract_class.instance_method(method).parameters
        #get teh dependency method parameters
        dmp = dependency_class.instance_method(method).parameters

        #check if the parameters match for both methods
        if cmp != dmp
          raise Sinject::DependencyContractInvalidParametersException.new(method, cmp)
        end

      end

    end

    def create_instance(item)
      instance = nil

      #check if a custom initializer block has been specified
      if item.initialize_block != nil
        #call the block to create the dependency instance
        instance = item.initialize_block.call

        #verify the block created the expected dependency type
        if !instance.is_a?(item.class_name)
          raise Sinject::DependencyInitializeException.new(item.class_name)
        end
      else
        instance = item.class_name.new
      end

      instance
    end
  end
end