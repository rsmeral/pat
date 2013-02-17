
class PlaintextRenderer
  attr_accessor :verbose, :group

  def initialize(verbose)
    @verbose = verbose
  end

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
      ret << message.time + "\t" + message.header + "\n"
    end
    ret
  end

  def long(messages, depth)
    ret = ""
    messages.each do |message|
      ret << message.day + ", " + message.time + "\t" + message.person + "\n" + message.header
      ret << "\n" + message.content if !message.content.nil?
      ret <<"\n------------------------------------------\n"
    end

    ret
  end

  def indent(string, width)
    string
    # string.gsub("\n", "X\n")# + (" " * (width * 2)))
  end

end