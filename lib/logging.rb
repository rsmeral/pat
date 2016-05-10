require 'logger'

class Logging
  
  @logger = Logger.new(STDERR)
  @logger.level = Logger::INFO
  @logger.formatter = proc do |severity, datetime, progname, msg|
    "#{severity}: #{msg}\n"
  end
  
  class << self
    attr_accessor :logger
  end
  
  def self.set_level(level)
    @logger.level = level
  end
end