require 'optparse'
require 'date'
require_relative 'person_manager'
require_relative 'service_manager'
require_relative 'model/person'

Dir["services/*"].each {|file| require_relative file }
Dir["renderers/*"].each {|file| require_relative file }
 
# Usage: /path/to/directory/*.rb
#               verbose                      force update 
#       user/proj  svc. configurations  time period
#   pat rsmeral -v -c github,jboss_jira -d 7 -f -r html

# begin
  
  # Defaults
  options = {
    days: 7,
    force: false,
    verbose: false,
    renderer: :plaintext
  }

  selected_persons = []

  # Parse command line options
  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: pat [OPTIONS] PERSON"
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
  
  end

  opt_parser.parse!

  # Parse selected persons
  ARGV.each do |arg|
    selected_persons << arg
  end

  # For each person
  selected_persons.each do |id|  
    person = PersonManager.person(id)
    
    # For each service configuration
    person.service_mappings.each do |service_id|
      if options[:selected_configurations].include?(service_id) then
        # Instantiate service
        svc_instance = ServiceManager.service_instance(service_id)

        # Prepare query
        query = Query.new(person)
        query.to = DateTime.now
        query.from = DateTime.now - Integer(options[:days])
      
        # Fetch data
        events = svc_instance.events(query)
      
        # Find renderer
        renderer_name = svc_instance.class.to_s.chomp("Service") + String.new(options[:renderer].to_s).capitalize + "Renderer"
        begin
          renderer_class = Object.const_get(renderer_name).inspect
        rescue
          puts "WARNING: Renderer #{renderer_name} not found. Falling back to plaintext."
          renderer_class = Object.const_get(svc_instance.class.to_s.chomp("Service") + "PlaintextRenderer")
        end
        renderer = renderer_class.new(options[:verbose])
        puts renderer.render(events)
      end
    end
  end
  
# rescue Exception => e
#   puts "Error!"
#   puts e
# end