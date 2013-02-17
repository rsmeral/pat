require 'json'

class JsonRenderer
  attr_accessor :verbose, :headers

  def initialize(verbose, group)
  end

  def render(messages)
    Message.class_eval do
      def to_json(a)
        hash = {}
        instance_variables.each { |var| hash[var.to_s.sub("@","")] = instance_variable_get(var) }
        JSON.pretty_generate(hash)
      end
    end

    JSON.pretty_generate(messages)
  end

end