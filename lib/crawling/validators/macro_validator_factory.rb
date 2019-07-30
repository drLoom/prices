require_relative 'total_macro_validator'

class MacroValidatorFactory
  def self.create_validator(type, options)
    case type
      when :total
        TotalMacroValidator.new(options)
      else
        raise 'Not implemented'
    end
  end
end
