require 'optparse'
require 'date'
require_relative 'person_manager'
require_relative 'service_manager'
require_relative 'basic_service_client'
require_relative 'model/person'
require_relative 'renderers/renderer'

Dir["services/*rb"].each {|file| require_relative file }
# Dir["renderers/*"].each {|file| require_relative file }

# begin
  
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

  opt.on("-v","--verbose","turns on long output") do
    options[:verbose] = true
  end

  opt.on("-f","--force-update","bypass cache") do
    options[:force] = true
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
  
  opt.on("-c","--configurations [x,y,z]","Array", "comma-separated list of service configurations to query") do |configurations|
    options[:selected_configurations] = configurations.split(",")
  end
  
  opt.on("-d","--days [n]","Numeric", "number of past days from today to query") do |days|
    options[:days] = days
  end
    
  opt.on("-r","--renderer [format]","String", "output format; fallback to plaintext if not found") do |renderer|
    options[:renderer] = renderer
  end
  
  opt.on("-g","--group [person,date,service]","Array", "comma-separated list; two element permutation of person,date,service; specifies grouping of events on output") do |group|
    options[:group] = group.nil? ? [] : group.split(",")
  end
  
end

opt_parser.parse!

# Parse selected persons
ARGV.each do |arg|
  selected_persons << arg
end

all_events = []

# For each person
selected_persons.each do |id|  
  person = PersonManager.person(id)
    
  # For each service configuration
  person.service_mappings.each_key do |service_id|
    if options[:selected_configurations].empty? || options[:selected_configurations].include?(service_id) then
      # Instantiate service
      svc_instance = ServiceManager.service_instance(service_id)

      # Prepare query
      query = Query.new(person)
      query.to = DateTime.now
      query.from = DateTime.now - Integer(options[:days])
      
      # Fetch data
      events = BasicServiceClient.do_query(svc_instance, query)
      all_events.concat(events)
    end# if selected
  end# each service
end# each person

renderer = Renderer.new(options[:verbose], options[:group], options[:renderer])
puts renderer.render(all_events)
  
# rescue Exception => e
#   puts "Error!"
#   puts e
# end