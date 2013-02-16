class JiraService
  
  @@Jira_API_path = "/rest/api/latest"
  
  attr_accessor :serviceUrl

  def initialize
  end
  
  def api_path
    serviceUrl + @@Jira_API_path
  end
  
  def get_events(query)
    
  end
  
end
