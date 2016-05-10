require_relative '../../model/message'
require_relative 'service_renderer_helper'
require 'pp'
require 'mail'

class ImapRenderer

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  include ServiceRendererHelper

  def process_event(event)
    d = event.data
    
    msg = Message.new
    msg.header = "Sent e-mail (#{d[:size].to_i}) to #{d[:envelope].to.map {|addr| addr.name.nil? ? "#{addr.mailbox}@#{addr.host}" : Mail::Encodings.value_decode(addr.name) }.join(", ")}: #{Mail::Encodings.value_decode(d[:envelope].subject)}"
    msg.content = ""
    
    msg
  end
  
  
end