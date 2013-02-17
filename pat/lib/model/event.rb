class Event
  attr_accessor :time, :data, :person
  attr_reader :service
  
  def initialize(service)
    @service = service
  end
  
  def to_s 
    "#{time} #{person.id}"
  end
  
end
