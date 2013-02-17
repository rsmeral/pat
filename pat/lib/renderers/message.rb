class Message
  attr_accessor :day, :time, :person, :service, :header, :content
  
  def initialize()
  end

  def to_s
    header
  end
  
end
