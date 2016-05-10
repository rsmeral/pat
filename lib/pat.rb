require_relative 'model/person'
require_relative 'renderers/renderer'
require_relative 'logging'
require 'thread'

class Pat

  attr_accessor :svc_mgr, :person_mgr

  def initialize(svc_mgr, person_mgr)
    @svc_mgr = svc_mgr
    @person_mgr = person_mgr
  end

  def retrieve_events(selected_persons, selected_services, days)
    all_events = []
    all_events_mutex = Mutex.new
    threads = []
    
    # For each enabled service configuration
    selected_services.each do |service_id|
      
      thr = Thread.new do
        svc_instance = svc_mgr.service_instance(service_id)
        
        # collect persons with this service enabled
        enabled_persons = selected_persons.map do |person_id|
          person = person_mgr.person(person_id)
          person.service_mappings[service_id].nil? ? nil : person
        end.compact

        # For each selected person that has non-nil service mapping
        enabled_persons.each do |person|
          # Prepare query
          query = Query.new(person)
          query.to = DateTime.now
          query.from = DateTime.now - days
          
          # Fetch data
          Logging.logger.info("Querying #{service_id} for #{person.id}")
          events = svc_instance.events(query)
          all_events_mutex.synchronize do
            all_events.concat(events)
          end # mutex
        end # persons
      end # thread
      
      threads.push thr
    end # services
    threads.each do |thr|
      thr.join
    end
    
    all_events
  end

  def render_events(selected_persons, selected_services, days, verbose, group, format)
    events = retrieve_events(selected_persons, selected_services, days)

    renderer = Renderer.new(verbose, group, format)
    renderer.render(events)
  end

end