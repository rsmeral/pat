class Event
  attr_accessor :time, :data
  attr_reader :service 
  
  def initialize(service)
    @service = service
  end
  
  def initialize(service, time, data)
    initialize(service)
    @time, @data = time, data
  end
  
end
