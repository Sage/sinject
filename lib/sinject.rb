require "sinject/version"


#This is the IOC Container for registering all dependencies an building objects.
class SinjectContainer

  class << self
    attr_accessor :instance
  end

  def initialize
    @store = []
    SinjectContainer.instance = self
  end

  # Check if an object has been registered with the container.
  #
  # Example:
  #   >> SinjectContainer.instance.is_registered? :object_key
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
  #   >> SinjectContainer.instance.register :object_key, ClassName, true, ContractName
  #
  # Arguments:
  #   key:  (Symbol)
  #   class_name: (ClassName)
  #   single_instance:  (Boolean)
  def register(key, dependency_class_name, single_instance = false, contract_class_name = nil, &initialize_block)

    #check if a contract has been specified
    if contract_class_name != nil
      #check if any contract methods are mising
      missing_methods = validate_contract(dependency_class_name, contract_class_name)
      if !missing_methods.empty?
        raise DependencyContractException.new(missing_methods)
      end
    end

    item = ContainerItem.new
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
  #   >> SinjectContainer.instance.get :object_key
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
      Object.const_get(class_name).new
    end
  end

  private

  def validate_contract(dependency_class, contract_class)
    #get the methods defined for the contract
    contract_methods = (contract_class.instance_methods - Object.instance_methods)
    #get the methods defined for the dependency
    dependency_methods = (dependency_class.instance_methods - Object.instance_methods)
    #calculate any methods specified in the contract that are not specified in the dependency
    contract_methods - dependency_methods
  end

  def create_instance(item)
    instance = nil

    #check if a custom initializer block has been specified
    if item.initialize_block != nil
      #call the block to create the dependency instance
      instance = item.initialize_block.call

      #verify the block created the expected dependency type
      if !instance.is_a?(item.class_name)
        raise DependencyInitializeException.new(item.class_name)
      end
    else
      instance = item.class_name.new
    end

    instance
  end
end

class ContainerItem
  attr_accessor :key
  attr_accessor :instance
  attr_accessor :single_instance
  attr_accessor :class_name
  attr_accessor :initialize_block
end

class Class

  # Specify a dependency required by a class.
  # This will create an attribute for the required dependency that will be populated by the ioc container.
  #
  # Example:
  #   >> dependency :registered_object_symbol
  #
  # Arguments:
  #   key:  (Symbol)
  def dependency(*obj_key)
    obj_key.each do |k|

      self.send(:define_method, k) do
        val = self.instance_variable_get("@#{k}")
        if(val == nil)
          val = SinjectContainer.instance.get(k)
          self.instance_variable_set("@#{k}", val)
        end
        val
      end

    end
  end
end

class DependencyContractException < StandardError
  def initialize(methods)
    @methods = methods
  end

  def to_s
    method_names = @methods.join(', ')
    "The following methods have not been implemented: '#{method_names}'"
  end
end

class DependencyInitializeException < StandardError

  def initialize(expected_type)
    @expected_type = expected_type
  end

  def to_s
    "The custom dependency initializer does not return an object of the expected type: '#{@expected_type}'"
  end

end
