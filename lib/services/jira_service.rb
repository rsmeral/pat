require 'json'
require 'pp'
require 'date'
require 'net/http'
require 'feedjira'
require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'
require_relative '../cached_http_client'

# JIRA service
# 
# Reports responses exactly as provided by the JIRA user activity feed.
# 
# If username and password is provided, reports also events from non-public projects.
# 
# HACK: this only returns at most 500 hundred events, as specified in the 'max_results' variable.
# Set to a higher value if necessary.
#
class JiraService
  
  include ServiceHelper
  
  @@max_results = 500
  
  # ID of this service instance
  attr_accessor :id
  
  # URL of the instance, e.g. http://issues.jboss.org
  attr_accessor :instance_url
  
  # username to get private activity
  attr_accessor :user
  
  # password to get private activity
  attr_accessor :password
  
  # Returns a list of events satisfying the query
  def events(query)
    ret = Array.new
    
    feed = Feedjira::Feed.parse jira_query(query)
    
    feed.entries.each do |feed_evt|
      event = event_from_feed(feed_evt)
      event.person = query.person
      
      if (event.time < query.to && event.time > query.from)
        ret << event
      end
    end
    
    ret
  end
  
  def event_from_feed(feed_entry)
    event = Event.new(self)
    event.time = DateTime.parse(feed_entry.updated.to_s).to_time.to_datetime
    event.data = feed_entry
    event
  end

  def jira_query(query)  
    
    if !user.nil? && !user.empty? && !password.nil? && !password.empty?
      uri = URI ("#{instance_url}/activity?maxResults=#{@@max_results}&os_authType=basic&streams=user+IS+#{user_id(query.person)}&streams=update-date+AFTER+#{query.from.to_date.to_time.to_i}")
      response = CachedHttpClient.new.get(uri, user, password)
    else
      uri = URI ("#{instance_url}/activity?maxResults=#{@@max_results}&streams=user+IS+#{user_id(query.person)}&streams=update-date+AFTER+#{query.from.to_date.to_time.to_i}")
      response = CachedHttpClient.new.get(uri)
    end
    
    if response.code != "200"
      raise "Error when accessing JIRA: #{response.code} #{response.message}"
    end
  
    response.body
  end
  
end