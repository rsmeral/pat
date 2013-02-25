class Query
  
  # The person to query for
  attr_accessor :person
  
  # The start time of the queried time span, has to be less than :to
  attr_accessor :from
  
  # The end time of the queried time span
  attr_accessor :to
  
  # Any parameters passed to the service
  attr_accessor :params
  
  def initialize(person)
    @person = person
  end
  
end
