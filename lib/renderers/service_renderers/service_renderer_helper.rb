module ServiceRendererHelper

  # Transforms an event into a Message object that is passed to renderers
  def message_from_event(event)
    message = process_event(event)
    
    if message.nil? 
      return nil
    end
    
    message.date = event.time.strftime("%b %d")
    message.time = event.time.strftime("%H:%M")
    message.person = event.person.name
    message.service = event.service.id

    message
  end
end