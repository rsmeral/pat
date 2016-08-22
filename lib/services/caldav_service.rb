require 'date'
require 'net/imap'
require 'pp'
require 'twisted-caldav'
require 'ice_cube'

require_relative '../model/event'
require_relative '../model/query'
require_relative 'service_helper'

# CalDAV service
# 
# Reports events in a person's calendar which occurred within the time range.
# In the URI configuration parameter, you can use the magic string '$user',
# which is replaced with the queried user's ID.
# 
# Very hacky implementation, not necessarily following the iCalendar standard.
# Events with the same summary and time are considered equivalent are merged.
# 
# FIXME: Attendance status and meeting status is not respected, therefore even cancelled and rejected events are reported.
#
class CaldavService

  include ServiceHelper

  # ID of this service instance
  attr_accessor :id
  attr_accessor :uri
  attr_accessor :username
  attr_accessor :password

  class SimpleEvt
    attr_accessor :time
    attr_accessor :summary
    attr_accessor :vevent
    
    def initialize(time=nil, summary=nil, vevent=nil)
      @time = time
      @summary = summary
      @vevent = vevent
    end
    
    def eql? (other)
      other.summary == @summary && other.time == @time
    end
    
    def hash
      [@time, @summary].hash
    end
    
  end

  # Returns a list of events satisfying the query
  def events(query)
    ret = Array.new
    
    set = Set.new
        
    (caldav_query(query) || []).each do |vevent|
      
      recurrent_occurrences = list_occurrences_within_range(vevent, query.from, query.to)
      
      if !recurrent_occurrences.empty?
        recurrent_occurrences.each do |occ|
          occevt = SimpleEvt.new
          occevt.time = DateTime.parse(occ.to_time.to_s)
          occevt.summary = vevent.summary.nil? ? "" : vevent.summary.strip
          occevt.vevent = vevent
          set << occevt
        end
      else
        evttime = vevent.properties["dtstart"]
        if evttime < query.to && evttime > query.from
          se = SimpleEvt.new
          se.time = evttime
          se.summary = vevent.summary.nil? ? "" : vevent.summary.strip
          se.vevent = vevent
          set << se
        end
      end
      
      ret
    end
    
    set.each do |elem|
      event = event_from_vevent(elem.vevent)
      event.time = elem.time
      event.person = query.person
      ret << event
    end
    
    ret
  end

  def list_occurrences_within_range(vevent, from, to)
    if vevent.properties["rrule"].nil?
      return []
    end
    
    schedule = IceCube::Schedule.new(Time.parse(vevent.properties["dtstart"].to_s))
    schedule.add_recurrence_rule(IceCube::IcalParser.rule_from_ical(vevent.properties["rrule"].first.instance_variable_get("@value")))
    
    schedule.occurrences_between(Time.parse(from.to_s), Time.parse(to.to_s), :spans => true)
  end

  def event_from_vevent(vevent)
    event = Event.new(self)
    event.time = vevent.properties["dtstart"]
    
    event.data = vevent
    
    event
  end
  
  def caldav_query(query)  
    vevents = Array.new
    
    cal = TwistedCaldav::Client.new(
      :uri => uri.gsub(/\$user/, user_id(query.person)),
      :user => username,
      :password => password
    )
    
    vevents = cal.find_events(
      :start => query.from.rfc3339,
      :end => query.to.rfc3339
    )
    
    vevents
  end

end
