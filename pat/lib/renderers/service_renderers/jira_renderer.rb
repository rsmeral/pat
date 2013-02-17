require_relative '../message'
require_relative 'service_renderer_helper'

class JiraRenderer

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  include ServiceRendererHelper

  def process_event(event)
    d = event.data
    header = "Filed #{d["key"]} #{d["fields"]["summary"]}"
    
    content = ""
    
    resolution = "#{d["fields"]["resolution"]}"
    if resolution.empty?
      resolution = "Unresolved"
    else
      resolution = "#{d["fields"]["resolution"]["name"]}"
    end
    
    content << "#{d["fields"]["issuetype"]["name"]}, #{d["fields"]["priority"]["name"]}, (#{d["fields"]["status"]["name"]}, #{resolution})\n"
    
    assignee = "#{d["fields"]["assignee"]}"
    if assignee.empty?
      assignee = "Unassigned"
    else
      assignee = "Assigned to #{d["fields"]["assignee"]["name"]}"
    end
    content << assignee
    
    ret = Message.new
    ret.header = header
    ret.content = content

    ret
  end
  
  
end