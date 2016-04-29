module Sinject
  class ContainerItem
    attr_accessor :key
    attr_accessor :instance
    attr_accessor :single_instance
    attr_accessor :class_name
    attr_accessor :initialize_block
  end
end