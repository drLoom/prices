require_relative 'presence_validator'
require_relative 'string_validator'

class ValidatorFactory
  def self.create_validator(arguments)
    name    = arguments.shift
    options = arguments[-1].is_a?(Hash) ? arguments.pop : {}
    fields  = arguments

    case name
      when :presence
        PresenceValidator.new(fields, options)
      when :string
        StringValidator.new(fields, options)
      else
        raise 'Not implemented'
    end
  end
end
