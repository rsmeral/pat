Dir["services/*rb"].each {|file| require_relative file }

class ServiceManager
  
  attr_accessor :data_dir
  
  def initialize(data_dir)
    @data_dir = data_dir
  end
  
  # Cache for service configuration instances
  @@configuration_cache = {}
  
  # Returns a service instance for the given service id
  def service_instance(id)
    @@configuration_cache[id] or @@configuration_cache[id] = Psych.load_file("#{data_dir}/service/#{id}")
  end

  def list_services
    Dir["#{data_dir}/service/*"].map {|file| file.sub(/^([.a-z_\/])*\//,"")}
  end
end
