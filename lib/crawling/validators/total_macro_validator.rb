require_relative 'macro_base_validator'

class TotalMacroValidator < MacroBaseValidator
  def validate(items)
    results = Hash.new(0)

    items.each do |item|
      fields.each do |field, field_opts|
        if field_opts[:ignore] && item[field].to_s[field_opts[:ignore]]
          next
        end

        results[field] += 1 if !item[field].blank? || field == :items
      end
    end

    output = {}
    results.each do |field, count|
      output[field] = {}
      output[field][:count] = count
      output[field][:required] = fields[field][:required]

      if fields[field][:less]
        output[field][:valid] = count <= fields[field][:required]
      else
        puts "output: #{output.inspect}"
        output[field][:valid] = count > fields[field][:required]
      end
    end

    { valid: output.all? { |_field, stats| stats[:valid] }, output: output }
  end
end
