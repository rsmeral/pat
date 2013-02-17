Dir["renderers/service_renderers/*.rb"].each {|file| require_relative file }
Dir["renderers/formats/*.rb"].each {|file| require_relative file }

class RendererManager

  attr_accessor :verbose

  def initialize(verbose)
    @verbose = verbose
  end

  def service_renderer(service)
    renderer_name = service.class.name.sub(/Service/, "Renderer")
    renderer_class = Object.const_get(renderer_name)

    renderer_class.new(verbose)
  end

  def format_renderer(format)
    renderer_name = format.capitalize + "Renderer"

    begin
      renderer_class = Object.const_get(renderer_name)
    rescue
      $stderr.puts "WARNING: Renderer #{renderer_name} not found. Falling back to plaintext."
      renderer_class = Object.const_get("PlaintextRenderer")
    end

    renderer_class.new(verbose)
  end

end