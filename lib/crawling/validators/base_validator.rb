require 'colorize'

class BaseValidator
  attr_reader :verbose, :fields

  def initialize(fields, options = {})
    @fields  = fields
    @verbose = options[:verbose]
  end

  def validate(item)
    raise 'Must be implemented'
  end
end
