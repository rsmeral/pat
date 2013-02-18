require 'json'
require 'date'
require 'net/http'
require 'net/https'
require 'csv'
require 'xmlsimple'
require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

class BugzillaService
  
  include ServiceHelper
  
  attr_accessor :id
  
  # URL of the instance
  attr_accessor :instance_url
  
  attr_reader :default_user_suffix

  def events(query)
    bug_ids = bz_list(query)
    
    bugs = XmlSimple.xml_in(bz_query(bug_ids))
    # bugs = XmlSimple.xml_in(File.read("demo/bz_#{query.person.id}.xml")) # DEMO
    
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

  
  def bz_query(bug_ids)
    params = {
      ctype: "xml",
      excludefield:	"attachmentdata",
      id: bug_ids
    }
    uri = URI ("#{instance_url}/show_bug.cgi")
    data = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl= true
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = data;
    response = http.request(req)
    
    if response.code != "200"
      raise "Error when accessing Bugzilla: #{response.code} #{response.message}"
    end

    response.body
  end 
  
  def bz_list(query)
    # return CSV.parse(File.read("demo/bz_#{query.person.id}.csv")).drop(1).collect { |item| item[0] } # DEMO
    
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
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl= true
    response = http.request(Net::HTTP::Get.new(uri.request_uri))

    if response.code != "200"
      raise 'Error when accessing Jira: #{response.code} #{response.message}'
    end
    
    CSV.parse(response.body).drop(1).collect { |item| item[0] }
  end
  
end