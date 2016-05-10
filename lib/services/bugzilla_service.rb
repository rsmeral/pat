require 'json'
require 'date'
require 'net/http'
require 'net/https'
require 'csv'
require 'pp'
require 'xmlsimple'
require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

# Bugzilla service
# 
# Reports modifications to bugs where the person is related in any way (reporter, assignee, commenter, 
# docs contact, qa contact). So, the report only states "Involved in..." without any more precision.
# That doesn't always mean that the person has made that modification, but most likely was at least notified.
# 
# No authentication. Only public data.
# 
# Issues two HTTP requests
# * one GET for the bug list CSV
# * one POST for the XML with actual bugs
#
class BugzillaService
  
  include ServiceHelper
  
  # ID of this service instance
  attr_accessor :id
  
  # URL of the instance
  attr_accessor :instance_url
  
  # The suffix to add to every username. Can be blank.
  attr_reader :default_user_suffix

  # Returns a list of events satisfying the query
  def events(query)
    Logging.logger.debug("Bugzilla: Getting bug list for #{user_id(query.person)}")
    bug_ids = bz_list(query)
    
    Logging.logger.debug("Bugzilla: Getting bug details for #{user_id(query.person)}")
    bugs = XmlSimple.xml_in(bz_query(bug_ids))
    
    (bugs["bug"].nil? ? {} : bugs["bug"]).map do |bug|
      event = event_from_xml(bug)
      event.person = query.person
      event
    end
  end
  
  def event_from_xml(bug)
    event = Event.new(self)
    
    event.time = DateTime.strptime(bug["delta_ts"][0], "%F %T %z")
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
    response = CachedHttpClient.new.post(uri, data)
    
    if response.code != "200"
      raise "Error when accessing Bugzilla: #{response.code} #{response.message}"
    end

    response.body
  end 
  
  # Get a list of bugs
  def bz_list(query)
    params = {
      f1: "delta_ts",
      o1: "greaterthan",
      v1: query.from.to_date.strftime("%Y-%m-%d"),
      
      f2: "delta_ts",
      o2: "lessthan",
      v2: query.to.to_date.strftime("%Y-%m-%d"),
      
      email1: default_user_suffix.nil? ? user_id(query.person) : user_id(query.person).chomp(default_user_suffix)+default_user_suffix,
      
      emailassigned_to1: "1",
      emaildocs_contact1: "1",
      emaillongdesc1: "1",
      emailqa_contact1: "1",
      emailreporter1: "1",
      emailtype1: "substring",
      
      query_format: "advanced",
      ctype: "csv"
    }
    
    
    uri = URI ("#{instance_url}/buglist.cgi")
    uri.query = URI.encode_www_form(params)
    response = CachedHttpClient.new.get(uri)

    if response.code != "200"
      raise 'Error when accessing Bugzilla: #{response.code} #{response.message}'
    end
    
    CSV.parse(response.body).drop(1).collect { |item| item[0] }
  end
  
end