class Event
  attr_accessor :time, :data
  attr_reader :service 
  
  def initialize(service)
    @service = service
  end
  
end
