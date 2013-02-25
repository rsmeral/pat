require 'json'
require 'date'
require 'net/http'
require 'net/https'
require 'csv'
require 'xmlsimple'
require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

# Requires two requests
# * one for the bug list CSV
# * second for the XML with actual bugs
class BugzillaService
  
  include ServiceHelper
  
  # ID of this service instance
  attr_accessor :id
  
  # URL of the instance
  attr_accessor :instance_url
  
  # The suffix to add to every username
  attr_reader :default_user_suffix

  # Returns a list of events satisfying the query
  def events(query)
    bug_ids = bz_list(query)
    
    bugs = XmlSimple.xml_in(bz_query(bug_ids))
    
    (bugs["bug"].nil? ? {} : bugs["bug"]).map do |bug|
      event = event_from_xml(bug)
      event.person = query.person
      event
    end
  end
  
  def event_from_xml(bug)
    event = Event.new(self)
    event.time = DateTime.strptime(bug["creation_ts"][0], "%F %T %z")
    event.data = bug
    event
  end

  # Retrieve the XML with bugs for given IDs
  def bz_query(bug_ids)
    params = {
      ctype: "xml",
      excludefield:	"attachmentdata",
      id: bug_ids
    }
    uri = URI ("#{instance_url}/show_bug.cgi")
    data = URI.encode_www_form(params)
    response = CachedHttpClient.post(uri, data)
    
    if response.code != "200"
      raise "Error when accessing Bugzilla: #{response.code} #{response.message}"
    end

    response.body
  end 
  
  # Get a list of bugs
  def bz_list(query)
    
    params = {
      f1: "reporter",
      o1: "equals",
      v1: user_id(query.person).chomp(default_user_suffix)+default_user_suffix,
      
      f2: "creation_ts",
      o2: "greaterthan",
      v2: query.from.to_date,
      
      f3: "creation_ts",
      o3: "lessthan",
      v3: query.to.to_date,
      
      bug_status: ["NEW", "ASSIGNED", "POST", "MODIFIED", "ON_DEV", "ON_QA", "VERIFIED", "RELEASE_PENDING", "CLOSED"],
      query_format: "advanced",
      ctype: "csv"
    }
    uri = URI ("#{instance_url}/buglist.cgi")
    uri.query = URI.encode_www_form(params)
    response = CachedHttpClient.get(uri)

    if response.code != "200"
      raise 'Error when accessing Jira: #{response.code} #{response.message}'
    end
    
    CSV.parse(response.body).drop(1).collect { |item| item[0] }
  end
  
end