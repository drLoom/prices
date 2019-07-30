require_relative '../data_storage'

module Loaders
  class RateLoader
    attr_accessor :file

    def initialize(opts = {})
      @file = opts[:file]
    end

    def load_data
      data = DataStorage.get_data_from_file(file)
      load_into_clickhouse(data)
    end

    def load_into_clickhouse(rates)
      rates = rates.map do |rate|
        rate[:rate] = rate[:rate].to_i

        rate.slice(:date, :currency, :rate)
      end

      Clickhouse::Client.conn.insert_rows('prices.rates', rows: rates)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require_relative '../../config/application'
  require_relative '../../config/environment'
  opts = Trollop::options do
    opt :file, "File with data", type: String
  end

  Loaders::RateLoader.new(opts).load_data
end
