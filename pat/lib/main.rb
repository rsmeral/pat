require_relative 'services/jira_service'

jira_instance = JiraService.new
jira_instance.serviceUrl = "http://issues.jboss.org"
puts jira_instance.api_path

class A
  
end