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
  #   >> SinjectContainer.instance.register :object_key, ClassName, true
  #
  # Arguments:
  #   key:  (Symbol)
  #   class_name: (ClassName)
  #   single_instance:  (Boolean)
  def register(key, class_name, single_instance = false)
    item = ContainerItem.new
    item.key = key
    item.single_instance = single_instance
    if single_instance == true
      item.instance = class_name.new
    else
      item.class_name = class_name
    end
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
    items = @store.select { |i| i.key == key}
    if !items.empty?
      item = items.first
      if item.single_instance == true
        return item.instance
      else
        return item.class_name.new
      end
    else
      class_name = "#{key}".split('_').collect(&:capitalize).join
      Object.const_get(class_name).new
    end
  end
end

class ContainerItem
  attr_accessor :key
  attr_accessor :instance
  attr_accessor :single_instance
  attr_accessor :class_name
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
