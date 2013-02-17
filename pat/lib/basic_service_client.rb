require_relative 'model/query'

class BasicServiceClient
  def self.do_query(svc_instance, query) 
    svc_instance.events(query)
  end
end
