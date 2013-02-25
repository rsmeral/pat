require 'json'

class JsonRenderer
  attr_accessor :verbose, :headers

  def initialize(verbose, group)
    @verbose = verbose
  end

  # Returns a JSON string representation of the messages list
  def render(messages)
    if verbose then
      Message.class_eval do
        @@option_verbose=true
      end
    else 
      Message.class_eval do
        @@option_verbose=false
      end
    end
    Message.class_eval do
      def to_json(a)
        hash = {}
        instance_variables.each { |var| hash[var.to_s.sub("@","")] = instance_variable_get(var) unless (!@@option_verbose && var.to_s=="@content") }
        JSON.pretty_generate(hash)
      end
    end

    JSON.pretty_generate(messages)
  end

end