require_relative 'base_validator'

class StringValidator < BaseValidator
  attr_reader :regexp

  def initialize(fields, options)
    super
    @regexp = options[:regexp]
  end

  def validate(item)
    @fields.each do |field|
      field_to_check = item[field]
      next unless field_to_check

      valid = field_to_check[regexp]

      unless valid
        item[:errors] ||= []
        item[:errors] << "#{field}: #{field_to_check} not matches: #{regexp}"
        puts "#{field} not matches: #{regexp}, item: #{item}".red if verbose
      end
    end
  end
end
