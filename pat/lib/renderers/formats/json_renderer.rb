require 'json'

class JsonRenderer
  attr_accessor :verbose, :headers

  def initialize(verbose, group)
  end

  def render(messages)
    Message.class_eval {
      def to_json(a)
        hash = {}
        instance_variables.each { |var| hash[var.to_s.sub("@","")] = instance_variable_get(var) }
        hash.to_json
      end
    }

    JSON.pretty_generate(messages)
  end

end