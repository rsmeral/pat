class JiraService
  
  @@Jira_API_path = "/rest/api/latest"
  
  attr_accessor :serviceUrl

  def initialize
  end
  
  def apiPath
    puts serviceUrl + @@Jira_API_path
  end
  
end
