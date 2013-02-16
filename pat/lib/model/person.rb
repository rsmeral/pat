class Person
  attr_accessor :name, :service_mappings
  
  def initialize(name, service_mappings)
    @name, @service_mappings = name, service_mappings
  end
  
end
