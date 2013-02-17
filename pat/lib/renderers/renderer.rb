require_relative '../renderer_manager'
require_relative 'message'

class Renderer
  
  attr_accessor :verbose, :group, :format
  
  def initialize(verbose, group, format)
    @verbose, @group, @format = verbose, group, format

    @renderer_manager = RendererManager.new(verbose)
    @renderer_cache = {}
  end
  
  def render(events)
    messages = events.map do |event|
      service_renderer(event.service).message_from_event(event)
    end
    # create deep equivalence class map
    message_classes = make_eq(messages, 0)
    # recursively render
    recursive_render(message_classes)
  end
  
  # convert message list to map of equivalence classes
  def make_eq(message_list, depth)
    # puts message_list.inspect
    # puts "#{depth} / #{ group.length}"
    if depth < group.length
      res = {}
      message_list.each do |message|
        (res[val(message,group[depth])] ||= []) << message
      end
      res.each_pair do |cls, sub_messages|
        res[cls] = make_eq(sub_messages, depth+1)
      end
      res
    else 
      return message_list;
    end
  end
  
  def val(message,criterion) 
    case criterion
      when "person"
        message.person
      when "date"
        message.day
      when "service"
        message.service
    end
  end
  
  def recursive_render(messages) 
    puts messages.inspect
    # check if list or hash
    # iterate over h.keys.sort
  end

  def service_renderer(service)
    if !@renderer_cache.has_key?(service)
      @renderer_cache[service] = @renderer_manager.service_renderer(service)
    end
    @renderer_cache[service]
  end
end
