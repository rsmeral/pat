class Service_Configuration
  attr_reader :clazz, :params
  
  def initialize(clazz, params)
    @clazz, @params = clazz, params
  end
end
