class Message
  attr_accessor :date, :time, :person, :service, :header, :content
  
  def initialize()
  end

  def to_s
    header
  end
  
end
