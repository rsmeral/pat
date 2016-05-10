require 'optparse'
require 'date'
require_relative 'person_manager'
require_relative 'service_manager'
require_relative 'cached_http_client'
require_relative 'pat'

# Defaults
do_list_only = nil
cli_options = {
  days: 7,
  force: false,
  verbose: false,
  renderer: :plaintext,
  group: ["person", "date"],
  selected_configurations: [],
  data_dir: "data",
  quiet: false
}

# Parse command line options
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: pat [OPTIONS] PERSON [PERSON...]"
  opt.separator  ""
  opt.separator  "Options"
  opt.separator  ""

  opt.on("-v","--verbose","turns on long output") do
    cli_options[:verbose] = true
  end

  opt.on("-f","--force-update","bypass cache") do
    cli_options[:force] = true
    CachedHttpClient.class_variable_set("@@force", cli_options[:force])
  end

  opt.on("-h","--help","help") do
    puts opt_parser
    exit
  end
  
  opt.on("-s","--services [x,y,z]","Array", "comma-separated list of services to query; default: all") do |configurations|
    cli_options[:selected_configurations] = configurations.split(",") unless configurations.nil?
  end
  
  opt.on("-d","--days [n]","Numeric", "number of past days from today to query; default: 7") do |days|
    cli_options[:days] = days
  end
    
  opt.on("-r","--renderer [format]","String", "output format; fallback to plaintext if not found") do |renderer|
    cli_options[:renderer] = renderer
  end
  
  opt.on("-g","--group [person,date,service]","Array", "comma-separated list; two element permutation", "of person,date,service; specifies grouping of events on output") do |group|
    cli_options[:group] =  group.split(",") unless group.nil?
  end

  opt.on("-l","--list persons|services|formats","String", "list all configured persons, services or formats") do |thing|
    do_list_only = thing
  end
  
  opt.on("-q","--quiet", "no logging output") do
    cli_options[:quiet] = true
  end
  
  opt.on("--data-dir [path]","String", "path to directory with person and service configurations") do |path|
    cli_options[:data_dir] = (path.start_with?("/") ? path : "../" + path)
  end
  
end

opt_parser.parse!

# Parse the rest of input - person list
selected_persons = []
ARGV.each do |arg|
  selected_persons << arg
end

# Main

svc_mgr = ServiceManager.new(cli_options[:data_dir])
psn_mgr = PersonManager.new(cli_options[:data_dir])
CachedHttpClient.class_variable_set(:@@data_dir, cli_options[:data_dir])
if(cli_options[:quiet])
  Logging.set_level(Logger::FATAL)
end
  

if !do_list_only.nil?
  puts case do_list_only
    when "persons" then psn_mgr.list_persons * "\n"
    when "services" then svc_mgr.list_services * "\n"
    when "formats" then RendererManager.list_formats * "\n"
  end
  exit
end

selected_persons = psn_mgr.list_persons if selected_persons.empty?
selected_confs = cli_options[:selected_configurations].empty?? svc_mgr.list_services : cli_options[:selected_configurations]

pat = Pat.new(svc_mgr, psn_mgr)

puts pat.render_events(
  selected_persons, 
  selected_confs, 
  Integer(cli_options[:days]),
  cli_options[:verbose],
  cli_options[:group],
  cli_options[:renderer])