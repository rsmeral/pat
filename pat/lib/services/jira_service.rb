require_relative '../model/query'

class JiraService
  
  attr_reader :id
  
  # URL of the instance, e.g. http://issues.jboss.org
  attr_accessor :instance_url
  
  # API path, e.g. /rest/api/latest
  attr_accessor :api_path

  def initialize(id, instance_url, api_path)
    @id, @instance_url, @api_path = id, instance_url, api_path
  end
  
  def get_events(query)
    person = query.person.name
    
  end
  
  def api_url 
    "#{instance_url}#{api_path}"
  end
  
end
