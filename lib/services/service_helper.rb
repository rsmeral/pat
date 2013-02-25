require_relative '../model/person'

module ServiceHelper
  
  # Return ID of the person in the service from which this method is called
  def user_id(person)
    person.service_mappings[id]
  end
  
end
