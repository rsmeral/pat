require_relative 'jira_service'
jira_instance = JiraService.new
jira_instance.serviceUrl = "http://issues.jboss.org"
jira_instance.apiPath

