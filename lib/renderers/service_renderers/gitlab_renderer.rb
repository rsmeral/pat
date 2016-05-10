require_relative '../../model/message'
require_relative 'service_renderer_helper'
require 'htmlentities'

class GitlabRenderer

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  include ServiceRendererHelper

  def process_event(event)
    d = event.data
    
    ret = Message.new
    ret.header = HTMLEntities.new.decode d.title.gsub(/<\/?[^>]*>/, "").strip.gsub(/\n/, " ").gsub(/  /, " ")
    if d.summary.nil?
      ret.content = ""
    else
      ret.content = HTMLEntities.new.decode d.summary.gsub(/<\/?[^>]*>/, "").strip.gsub(/\n/, "").gsub(/  /, " ")
    end
    
    ret
  end
  
  
end