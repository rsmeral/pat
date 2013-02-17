module RendererHelper
  
  attr_accessor :verbose, :group
  
  renderer_cache = {}
  
  def initialize(verbose, group)
    @verbose, @group = verbose, group
  end
  
  def render(events)
    # create deep equivalence class map
    event_classes = make_eq(events, 0)
    # recursively render
    recursive_render(event_classes)
  end
  
  # convert event list to map of equivalence classes
  def make_eq(event_list, depth)
    # puts event_list.inspect
    # puts "#{depth} / #{ group.length}"
    if depth < group.length
      res = {}
      event_list.each do |event|
        (res[val(event,group[depth])] ||= []) << event
      end
      res.each_pair do |cls, sub_events|
        res[cls] = make_eq(sub_events, depth+1)
      end
      res
    else 
      return event_list;
    end
  end
  
  def val(event,criterion) 
    case criterion
      when "person"
        event.person.id
      when "date"
        event.time.to_date
      when "service"
        event.service
    end
  end
  
  def recursive_render(events) 
    puts events.inspect
    # check if list or hash
    # iterate over h.keys.sort
  end
end
