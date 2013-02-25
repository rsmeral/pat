class Event
  
  # Time of occurrence
  attr_accessor :time
  
  # The actor of this event
  attr_accessor :person
  
  # A reference to the service from to which this event pertains
  attr_reader :service
  
  # Payload returned from the service
  attr_accessor :data
  
  def initialize(service)
    @service = service
  end
  
  def to_s 
    "#{time} #{person.id}"
  end
  
end
