module PlaintextRendererHelper
  def short(event, output)
    puts event.time.strftime("%b %d, %H:%M") + "\t" + output
  end

  def long(event, output)
    puts event.time.strftime("%b %d, %H:%M") + "\n" + output + "\n"
  end

end