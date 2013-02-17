
class PlaintextRenderer
  def short(messages)
    ret = ""
    last_person = ""
    last_day = ""
    messages.each do |message|
      ret << "#{message.person}\n" if last_person != message.person
      ret << "#{message.day}\n" if last_day != message.day
      ret << "  " + message.time + "\t" + message.content + "\n"
      last_day = message.day
      last_person = message.person
    end

    ret
  end

  def long(messages)
    ret = ""
    messages.each do |message|
      ret << message.day + ", " + message.time + "\t" + message.person + "\n" + message.content + "\n------------------------------------------\n"
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

end