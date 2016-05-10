require 'date'
require 'net/https'

# Simple HTTP request cache
# 
# Caches HTTP responses serialized to YAML in a cache folder for a configured 
# amount of time. The file names are SHA hashes of the request.
# 
class CachedHttpClient
  
  class SimpleRequest
    
    attr_accessor :uri, :method, :user, :password, :data
    
    def initialize(uri=nil, method=nil, user=nil, password=nil, data=nil)
      @uri = uri
      @method = method
      @user = user
      @password = password
      @data = data
    end
    
    def eql? (other)
      other.uri == @uri &&
      other.method == @method &&
      other.user == @user &&
      other.password == @password &&
      other.data == @data
    end
    
    def hash
      [@uri, @method, @user, @password, @data].hash
    end
    
  end
  
  @@force = false
  @@interval = 300 # seconds
  @@ua = "pat/1.0"
  @@data_dir = "/tmp/pat-http-cache"
  
  def initialize(insecure=false)
    @insecure = insecure
  end
  
  def get(uri, user=nil, password=nil)
    retrieve(SimpleRequest.new(uri, Net::HTTP::Get, user, password))
  end
  
  def post(uri, data, user=nil, password=nil)
    retrieve(SimpleRequest.new(uri, Net::HTTP::Post, user, password, data))
  end
  
  def retrieve(sreq)
    file_name = "#{cache_dir}/#{cache_key(sreq)}"
    if File.exist?(file_name) # check if cache entry valid
      cached_file = File.read(file_name)
      last_fetched = DateTime.parse(cached_file.lines.first.chomp)
      
      if (DateTime.now - last_fetched)*24*60*60 > @@interval # cache miss
        cache_refresh(sreq)
      else # cache hit
        if @@force
          cache_refresh(sreq)
        else
          return Psych.load(cached_file.lines.to_a[1..-1].join)
        end
      end
    else # cache miss, get and store
      cache_refresh(sreq)
    end
  end
  
  def cache_refresh(sreq)
    response = http_request(sreq)
    File.open("#{cache_dir}/#{cache_key(sreq)}", 'w') do |file| 
      file.write(DateTime.now.to_s + "\n")
      file.write(response.to_yaml)
    end
    response
  end
  
  def cache_key(sreq)
    Dir.mkdir(cache_dir) unless Dir.exist?(cache_dir)
    cat = [:uri, :method, :user, :password, :data].reduce("") do |acc, e|
      acc + sreq.send(e).to_s
    end
    Digest::SHA2.hexdigest(cat)
  end
  
  def cache_dir
    "#{@@data_dir}/cache"
  end
  
  def http_request(sreq)
    # Set up HTTP connection
    http = Net::HTTP.new(sreq.uri.host, sreq.uri.port)
    http.use_ssl = sreq.uri.to_s.start_with?("https")
    if @insecure
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    # Instantiate request object of proper type
    req = sreq.method.new(sreq.uri.request_uri)
    
    # Set up headers
    req.basic_auth(sreq.user, sreq.password) unless sreq.user.nil? || sreq.password.nil?
    req.body = sreq.data unless sreq.data == nil
    req["User-Agent"] = @@ua
    
    http.request(req)
  end
  
end
