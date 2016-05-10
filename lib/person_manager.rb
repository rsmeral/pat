require 'yaml'

class PersonManager
  
  attr_accessor :data_dir
  
  def initialize(data_dir)
    @data_dir = data_dir
  end
  
  # Return person instance from file if exists, or a synthetic person with all values equal to id
  def person(id)
    begin 
      # configured
      p = Psych.load_file("#{data_dir}/person/#{id}")
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

  def list_persons
    Dir["#{data_dir}/person/*"].map {|file| file.sub(/^([.a-z_\/])*\//,"")}
  end
end
