require 'optparse'
require_relative 'person_manager'
require_relative 'service_manager'
require_relative 'model/person'
require_relative 'services/jira_service'
require_relative 'services/github_service'


# parse services
# Dir.glob("services/*.rb").each { |item| 
#  require_relative item
  
#}

# parse renderers
# parse settings (persons, service configurations)

# get events for person
# get service_configurations
# 
 
# Usage: 
#               verbose                      force update 
#       user/proj  svc. configurations  time period
#   pat rsmeral -v -c github,jboss_jira -d 7 -f 

begin
  
  # Defaults
  options = {
    days: 7,
    force: false,
    verbose: false
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
    person.service_mappings.each_pair do |service_id, user_id|
      svc_instance = ServiceManager.service_instance(service_id)
      
      svc_instance.events(Query.new(user_id))
      
    end
  end

  # puts options.inspect
  # puts selected_persons.inspect
  
rescue Exception => e
  puts "Error!"
  puts e.message
end