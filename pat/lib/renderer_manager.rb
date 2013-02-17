Dir["renderers/service_renderers/*.rb"].each {|file| require_relative file }
Dir["renderers/formats/*.rb"].each {|file| require_relative file }

class RendererManager

  attr_accessor :verbose, :group

  def initialize(verbose, group)
    @verbose = verbose
    @group = group
  end

  def service_renderer(service)
    renderer_name = service.class.name.sub(/Service/, "Renderer")
    renderer_class = Object.const_get(renderer_name)

    renderer_class.new(verbose)
  end

  def format_renderer(format)
    renderer_name = format.to_s.capitalize + "Renderer"

    begin
      renderer_class = Object.const_get(renderer_name)
    rescue
      $stderr.puts "WARNING: Renderer #{renderer_name} not found. Falling back to plaintext."
      renderer_class = Object.const_get("PlaintextRenderer")
    end

    renderer_class.new(verbose, group)
  end

end