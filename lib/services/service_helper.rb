require_relative '../model/person'

module ServiceHelper
  
  def user_id(person)
    person.service_mappings[id]
  end
  
end
