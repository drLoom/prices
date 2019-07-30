class MacroBaseValidator
  attr_reader :verbose, :fields

  def initialize(options = {})
    @fields = options
  end

  def validate(items)
    raise 'Must be implemented'
  end
end