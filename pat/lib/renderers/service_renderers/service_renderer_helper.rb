module ServiceRendererHelper

  def message_from_event(event)
    message = process_event(event)
    message.day = event.time.strftime("%b %d")
    message.time = event.time.strftime("%H:%M")
    message.person = event.person.name
    message.service = event.service.id

    message
  end
end