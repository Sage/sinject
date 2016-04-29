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
          val = Sinject::Container.instance.get(k)
          self.instance_variable_set("@#{k}", val)
        end
        val
      end

    end
  end
end