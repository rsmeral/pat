require_relative '../message'
require_relative 'service_renderer_helper'

class BugzillaRenderer

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  include ServiceRendererHelper

  def process_event(event)
    d = event.data
    header = "Filed \##{d["bug_id"][0]} #{d["short_desc"][0]}"
    
    content = ""
    
    content << "#{d["product"][0]}, #{d["version"][0]}, #{d["component"][0]}\n"
    content << "(#{d["bug_status"][0]}) #{d["priority"][0]} priority, #{d["bug_severity"][0]} severity"
    
    ret = Message.new
    ret.header = header
    ret.content = content

    ret
  end
  
  
end