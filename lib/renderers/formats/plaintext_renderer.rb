class PlaintextRenderer
  attr_accessor :verbose, :headers

  def initialize(verbose, group)
    @verbose = verbose
    @headers = [:date, :time, :person, :service] - group.map {|x| x.to_sym}
  end

  # Returns a formatted plain text representation of the messages
  def render(messages, depth = 0)
    ret = ""
    if messages.class == Hash
      ret << indent(render_hash(messages, depth + 1), depth)
      ret << "\n"
    elsif messages.class == Array
      ret << indent(render_list(messages, depth + 1), depth)
    end

    ret
  end

  private

  
  ###  Helper methods
  
  def render_hash(messages, depth)
    ret = ""
    messages.each_pair do |header, hash|
      ret << header + "\n"
      ret << render(hash, depth + 1)
    end

    ret
  end

  def render_list(messages, depth)
    if verbose
      long(messages, depth)
    else
      short(messages, depth)
    end
  end

  def short(messages, depth)
    ret = ""
    messages.each do |message|
      headers.each do |header|
        ret << message.send(header) + "    "
      end
      ret << message.header + "\n"
    end
    ret
  end

  def long(messages, depth)
    ret = ""
    messages.each do |message|
      headers.each do |header|
        ret << message.send(header) + "    "
      end
      ret << "\n" + message.header
      ret << "\n" + message.content if !message.content.nil?
      ret << "\n------------------------------------------\n"
    end

    ret
  end

  def indent(str, depth)
    str.lines("\n").map { |line| (" "*depth) + line }.join
  end

  def header_data
    [:date, :time, :person, :service]
  end

end