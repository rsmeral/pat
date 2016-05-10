require 'json'
require 'date'
require 'net/http'

require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

# Gitlab service
# 
# Reports responses exactly as provided by the Gitlab user activity feed.
# 
# Doesn't support authentication.
#
class GitlabService

  include ServiceHelper

  # ID of this service instance  
  attr_accessor :id
  
  # URL of the Gitlab instance
  attr_accessor :instance_url
  
  # Returns a list of events satisfying the query
  def events(query)
    ret = Array.new
    
    feed = Feedjira::Feed.parse gitlab_query(query)
    
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
  
  def gitlab_query(query)
    
    uri = URI ("#{instance_url}/u/#{user_id(query.person)}.atom")
    response = CachedHttpClient.new(true).get(uri)
    
    if response.code != "200"
      raise "Error when accessing Gitlab: #{response.code} #{response.message}"
    end
  
    response.body
  end

end
