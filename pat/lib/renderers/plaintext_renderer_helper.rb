module PlaintextRendererHelper
  def short(messages)
    ret = ""
    messages.each do |message|
      ret << "#{message.day}\n" if last_day != message.day
      ret << "  " + message.time + "\t" + message.content + "\n"
      last_day = message.day
    end

    ret
  end

  def long(message)
    ret = ""
    messages.each do |message|
      ret << message.day + " " + message.time + "\n" + message.content + "\n------------------------------------------"
      last_day = message.day
    end

    ret
  end

  def render(events)
    messages = events.collect do |event|
      message_from_event(event)
    end
    if verbose
      long(messages)
    else
      short(messages)
    end
  end

  def message_from_event(event)
    message = PlaintextMessage.new
    message.day = event.time.strftime("%b %d")
    message.time = event.time.strftime("%H:%M")
    message.user = "jozo"
    message.content = base.process_event(event)
  end

end