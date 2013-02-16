class ServiceManager
  
  # Cache for service configuration instances
  @@configuration_cache = {}
  
  # Returns a service instance for the given service configuration
  def self.service_instance(id)
    @@configuration_cache[id] or @@configuration_cache[id] = Psych.load_file("data/service/#{id}")
  end
end
