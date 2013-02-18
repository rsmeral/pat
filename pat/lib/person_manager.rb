require 'yaml'

class PersonManager
  
  # Return person instance from file if exists, or a synthetic person with all values equal to id
  def self.person(id)
    begin 
      # configured
      p = Psych.load_file("data/person/#{id}")
      p.configured = true
      p
    rescue 
      # synthetic
      h = Hash.new
      h.default=id
      p = Person.new(id, id, h)
      p.configured = false
      p
    end
  end

  def self.list_persons
    Dir["data/person/*"].map {|file| file.sub(/^([.a-z_\/])*\//,"")}
  end
end
