require_relative '../../../lib/sinject'
class SingleInstance

end

class MultiInstance

end

class HelloWorld
  attr_accessor :value

  def initialize
    self.value = "Hello World"
  end
end

class GoodbyeWorld
  attr_accessor :value

  def initialize
    self.value = "Goodbye World"
  end
end

class ObjectWithDependency
  dependency :hello_world
  dependency :goodbye_world
end

class CustomLogger
  def write

  end
end
class LoggerContract
  def write

  end
end

class CacheControlContract
  def set(key, value)

  end
end

class RedisCacheControl
  def set(key, value, expires)

  end
end

class TestDependencyGroup < DependencyGroup
  def register(container)
    container.register(:hello_world, HelloWorld, true)
    container.register(:goodbye_world, GoodbyeWorld, true)
  end

  def is_valid?
    return true
  end
end

class TestDependencyGroup2 < DependencyGroup
  def register(container)
    container.register(:logger, CustomLogger, true)
  end

  def is_valid?
    return false
  end
end




