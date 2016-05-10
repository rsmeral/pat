require 'json'
require 'date'
require 'net/http'
require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

class GithubService

  include ServiceHelper

  # ID of this service instance  
  attr_accessor :id
  
  # personal access token
  attr_accessor :token
  
  # repos to scan for events, in addition to the user events
  attr_accessor :repos
  
  # Returns a list of events satisfying the query
  def events(query)
    ret = Array.new
    page = 1
    json_array = Array.new
    loop do
      json_array.concat JSON.parse(github_query(user_id(query.person), page))
      puts "page " + page.to_s
      page += 1
      break if DateTime.iso8601(json_array[-1]["created_at"]) < query.from
    end
    
    json_array.each do |event_json|
      event = event_from_json(event_json)
      event.person = query.person
      
      if (event.time < query.to && event.time > query.from)
        ret << event
      end
    end

    ret
  end

  private

  def event_from_json(json_data)
    event = Event.new(self)
    event.time = DateTime.iso8601(json_data["created_at"])
    event.data = json_data
    
    event
  end

  def github_query(user, page=1)
    uri = URI.parse("https://api.github.com/users/#{user}/events?page=#{page}")
    if :token != nil
      response = CachedHttpClient.http_basic_auth_get(uri,user,token)
    else
      response = CachedHttpClient.get(uri)
    end
    
    if response.code != "200"
      raise "Error when accessing GitHub: #{response.code} #{response.message}"
    end

    response.body
  end

end
