module Sinject
  class DependencyGroup
    def register(container)
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
  end
end
