require_relative '../../model/message'
require_relative 'service_renderer_helper'
require 'pp'
require 'mail'

class CaldavRenderer

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  include ServiceRendererHelper

  def process_event(event)
    d = event.data
    
    duration_min = ((event.data.properties["dtend"] - event.data.properties["dtstart"]) * 24 *60).to_i
    attendees = event.data.properties["attendee"]
    has_attendees = !attendees.nil?
    attendee_num = has_attendees ? attendees.size : 0
    
    msg = Message.new
    msg.header = "Meeting with #{attendee_num} #{attendee_num > 1 ? 'people' : 'person'} (#{duration_min} min.): #{d.summary}"
    msg.content = ""
    
    if has_attendees
      attendee_list = attendees.map { |att|
        att.to_s.sub(/mailto:/, "")
      }.join(', ')
      
      msg.content += "Attendees: #{attendee_list} \n"
    end
    
    msg.content += "#{event.data.properties['description']}"
    
    msg
  end
  
end