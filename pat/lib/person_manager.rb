require 'yaml'

class PersonManager
  
  # Return person instance
  def self.person(id)
    Psych.load_file("data/person/#{id}")
  end
end
