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
  def write(text, format=:json, location:, foo: 'bar')
  end
end
class LoggerContract
  def write(text, format, location:, foo:)
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

class TestDependencyGroup < Sinject::DependencyGroup
  def register(container)
    container.register({ :key => :hello_world, :class => HelloWorld, :singleton => true })
    container.register({ :key => :goodbye_world, :class => GoodbyeWorld, :singleton => true})
  end

  def valid?
    return true
  end
end

class TestDependencyGroup2 < Sinject::DependencyGroup
  def register(container)
    container.register({ :key => :logger, :class => CustomLogger, :singleton => true})
  end

  def valid?
    return false
  end
end




