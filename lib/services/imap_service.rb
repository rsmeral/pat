require 'date'
require 'net/imap'
require 'pp'

require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

# IMAP service
# 
# Reports messages located in the given folders sent by the given user in the given time range.
# Only fetches headers. Reports message subject, size, and recipients.
# 
# Username and password required.
# 
class ImapService

  include ServiceHelper

  # ID of this service instance
  attr_accessor :id
  attr_accessor :server
  attr_accessor :ssl
  attr_accessor :port
  attr_accessor :folders
  attr_accessor :username
  attr_accessor :password

  # Returns a list of events satisfying the query
  def events(query)
    ret = Array.new
    imap_query(query).each do |env|
      event = event_from_envelope(env)
      event.person = query.person
      ret.push event
    end
    
    ret
  end

  def event_from_envelope(env)
    event = Event.new(self)
    event.time = DateTime.parse(env[:envelope].date.to_s)
    event.data = env
    
    event
  end
  
  def imap_query(query)    
    mails = Array.new
    
    imap = Net::IMAP.new(server, port, ssl: (ssl == "true"))
    imap.login(username, password)
    folders.each do |folder|
      imap.select(folder)
      imap.search(["SINCE", query.from.to_date.strftime("%e-%b-%Y"), "FROM", user_id(query.person)]).each do |msg_id|
        env = imap.fetch(msg_id, ["ENVELOPE", "RFC822.SIZE"])[0]
        mails.push ({ envelope: env.attr["ENVELOPE"], size: env.attr["RFC822.SIZE"] })
      end
    end
    imap.logout
    imap.disconnect
    
    mails
  end

end
