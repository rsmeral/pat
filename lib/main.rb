require 'optparse'
require 'date'
require_relative 'person_manager'
require_relative 'service_manager'
require_relative 'model/person'
require_relative 'renderers/renderer'

Dir["services/*rb"].each {|file| require_relative file }

# Defaults
options = {
  days: 7,
  force: false,
  verbose: false,
  renderer: :plaintext,
  group: ["person", "date"],
  selected_configurations: ServiceManager.list_services
}

selected_persons = []

# Parse command line options
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: pat [OPTIONS] PERSON [PERSON...]"
  opt.separator  ""
  opt.separator  "Options"
  opt.separator  ""

  opt.on("-v","--verbose","turns on long output") do
    options[:verbose] = true
  end

  opt.on("-f","--force-update","bypass cache") do
    options[:force] = true
  end

  opt.on("-h","--help","help") do
    puts opt_parser
    exit
  end
  
  opt.on("-s","--services [x,y,z]","Array", "comma-separated list of services to query; default: all") do |configurations|
    options[:selected_configurations] = configurations.split(",") unless configurations.nil?
  end
  
  opt.on("-d","--days [n]","Numeric", "number of past days from today to query; default: 7") do |days|
    options[:days] = days
  end
    
  opt.on("-r","--renderer [format]","String", "output format; fallback to plaintext if not found") do |renderer|
    options[:renderer] = renderer
  end
  
  opt.on("-g","--group [person,date,service]","Array", "comma-separated list; two element permutation", "of person,date,service; specifies grouping of events on output") do |group|
    options[:group] =  group.split(",") unless group.nil?
  end

  opt.on("-l","--list persons|services|formats","list all configured persons, services or formats") do |thing|
    puts list(thing)
    exit
  end
  
end

def list(thing)
  puts case thing
  when "persons" then PersonManager.list_persons * "\n"
  when "services" then ServiceManager.list_services * "\n"
  when "formats" then RendererManager.list_formats * "\n"
  end
end

opt_parser.parse!

# Parse selected persons
ARGV.each do |arg|
  selected_persons << arg
end

selected_persons = PersonManager.list_persons if selected_persons.empty?

all_events = []

# For each enabled service configuration
options[:selected_configurations].each do |service_id|
  svc_instance = ServiceManager.service_instance(service_id)
  
  # For each selected person that has non-nil service mapping
  selected_persons.each do |id|
    person = PersonManager.person(id)
    
    if !person.service_mappings[service_id].nil?
        
      # Prepare query
      query = Query.new(person)
      query.to = DateTime.now
      query.from = DateTime.now - Integer(options[:days])
      
      # Fetch data
      events = svc_instance.events(query)
      all_events.concat(events)
    end
  end
end

renderer = Renderer.new(options[:verbose], options[:group], options[:renderer])
puts renderer.render(all_events)
