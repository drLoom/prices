require_relative 'base_validator'

class PresenceValidator < BaseValidator
  def validate(item)
    @fields.each do |field|
      invalid = item[field].blank?

      if invalid
        item[:errors] ||= []
        item[:errors] << "#{field} blank"
        puts "#{field} blank, item: #{item}".red if verbose
      end
    end
  end
end
