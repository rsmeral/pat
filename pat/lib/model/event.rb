class Event
  attr_accessor :time, :text
  attr_reader :service 
  
  def initialize(service)
    @service = service
  end
  
  def initialize(service, time, text)
    initialize(service)
    @time, @text = time, text
  end
  
end
