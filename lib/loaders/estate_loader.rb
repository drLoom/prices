require_relative '../data_storage'

module Loaders
  class EstateLoader
    attr_accessor :file

    def initialize(opts = {})
      @file = opts[:file]
    end

    def load_data
      data = DataStorage.get_data_from_file(file)
      load_into_clickhouse(data)
    end

    def load_into_clickhouse(flats)
      flats = flats.map do |flat|
        flat[:date]          = Date.today.strftime('%Y-%m-%d')
        flat[:price]         = (flat[:price].to_f * 100).floor
        flat[:meter_price]   = flat[:meter_price] ? (flat[:meter_price].to_f * 100).floor : nil
        flat[:house_year]    = flat[:house_year].to_i
        flat[:ad_created_at] = flat[:ad_created_at] ? flat[:ad_created_at] : '0000-00-00'
        flat[:total_area]    = flat[:total_area] ? (flat[:total_area].to_f * 100).floor : nil
        flat[:living_room]   = flat[:living_room] ? (flat[:living_room].to_f * 100).floor : nil
        flat[:kitchen_area]  = flat[:kitchen_area] ? (flat[:kitchen_area].to_f.abs * 100).floor : nil
        flat[:timestamp]     = Time.now.strftime('%Y-%m-%d %H:%M:%S')

        flat.except(:created_at, :page_url, :updated_at)
      end

      Clickhouse::Client.conn.insert_rows('prices.estate', rows: flats)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require_relative '../../config/application'
  require_relative '../../config/environment'
  opts = Trollop::options do
    opt :file, "File with data", type: String
  end

  Loaders::EstateLoader.new(opts).load_data
end
