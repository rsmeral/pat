module ServiceRendererHelper

  def message_from_event(event)
    message = Message.new
    message.day = event.time.strftime("%b %d")
    message.time = event.time.strftime("%H:%M")
    message.person = event.person.name
    message.service = event.service.id

    event_data = process_event(event)
    message.header = event_data.header
    message.content = event_data.content

    message
  end
end