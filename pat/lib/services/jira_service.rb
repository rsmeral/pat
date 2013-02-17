require 'json'
require 'date'
require 'net/http'
require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

class JiraService
  
  include ServiceHelper
  
  attr_accessor :id
  
  # URL of the instance, e.g. http://issues.jboss.org
  attr_accessor :instance_url
  
  # API path, e.g. /rest/api/latest
  attr_accessor :api_path
  
  def events(query)
    # JSON.parse(jira_query(query))["issues"].map do |json_evt|
    JSON.parse(File.read("rsmeral_issues.json"))["issues"].map do |json_evt|
      event = event_from_json(json_evt)
      event.person = query.person
      event
    end
  end
  
  def event_from_json(json_data)
    event = Event.new(self)
    event.time = DateTime.iso8601(json_data["fields"]["created"])
    event.data = json_data
    event
  end

  def jira_query(query)
    params = {
      jql: "reporter=#{user_id(query.person)} AND createdDate>=#{query.from.to_date} AND createdDate<=#{query.to.to_date} ORDER BY created DESC, key DESC",
      fields: "key,summary,issuetype,priority,status,reporter,description,created,assignee,resolution"
    }
    uri = URI ("#{api_url}/search")
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))

    if response.code != "200"
      raise "Error when accessing Jira: #{response.code} #{response.message}"
    end

    response.body
  end
  
  def api_url 
    "#{instance_url}#{api_path}"
  end
  
end