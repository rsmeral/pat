require 'date'

# TODO: Needs refactoring...

# Ugly HTTP request caching based on URL
# Caches HTTP responses serialized to YAML in a cache folder for a configured 
# amount of time. The file names are SHA hashes of the URLs. Only caches GET, 
# all POST requests pass through.
class CachedHttpClient
  
  @@force = false
  @@interval = 300 # seconds
  @@cache = "data/cache"
  
  def self.get(uri)
    # have cached response?
    file_name = cache_filename(uri)
    if File.exist?(file_name)
      cached_file = File.read(file_name)
      last_fetched = DateTime.parse(cached_file.lines.first.chomp)
      
      # is cached response old? refresh it
      if (DateTime.now - last_fetched)*24*60*60 > @@interval
        cache_refresh_get(uri)
      else # cached response is not old, return it

        if @@force
          cache_refresh_get(uri) 
        else
          return Psych.load(cached_file.lines.to_a[1..-1].join)
        end
      end
    else # don't have a cached response, get and store
      cache_refresh_get(uri) 
    end
  end
  
  def self.cache_refresh_get(uri) 
    response = http_get(uri)
    File.open(cache_filename(uri), 'w') do |file| 
      file.write(DateTime.now.to_s + "\n")
      file.write(response.to_yaml)
    end
    return response
  end
  
  def self.cache_filename(uri)
    uri_hash = Digest::SHA2.hexdigest(uri.to_s)
    "#{@@cache}/#{uri_hash}"
  end
  
  def self.http_get(uri)
    ssl = uri.to_s.start_with?("https")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = ssl
    http.request(Net::HTTP::Get.new(uri.request_uri))
  end
    
  # NO CACHING FOR POST YET
  
  def self.post(uri,data)
    http_post(uri,data)
  end
  
  def self.http_post(uri, data)
    ssl = uri.to_s.start_with?("https")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = ssl
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = data;
    http.request(req)
  end
  
end
