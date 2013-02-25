class Message
  
  # Same semantics as in Event
  
  attr_accessor :time
  attr_accessor :person
  attr_accessor :service
  
  
  # Date portion of time
  attr_accessor :date
  
  # A one line summary of the message
  attr_accessor :header
  
  # Full contents
  attr_accessor :content
  
  def initialize()
  end
  
end
