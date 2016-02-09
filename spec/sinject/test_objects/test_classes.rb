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




