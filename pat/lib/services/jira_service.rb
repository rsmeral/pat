require_relative '../model/query'

class JiraService
  
  attr_accessor :id
  
  # URL of the instance, e.g. http://issues.jboss.org
  attr_accessor :instance_url
  
  # API path, e.g. /rest/api/latest
  attr_accessor :api_path
  
  def events(query)
    
    
  end
  
  def api_url 
    "#{instance_url}#{api_path}"
  end
  
end
