require_relative '../parser_base'

class Nbrb < ParserBase
  domain     'nbrb'
  start_urls "http://www.nbrb.by/API/ExRates/Rates/Dynamics/145?ParamMode=1&startDate=#{(Date.today - 360).strftime('%Y-%m-%d')}&endDate=#{Date.today.strftime('%Y-%m-%d')}"

  CURRENCIES = {
    145 => 'USD'
  }

  def parse(response, data = {})
    JSON(response[:body]).each do |curr_data|
      curr_rate            = {}

      curr_rate[:currency] = CURRENCIES[curr_data['Cur_ID']]
      curr_rate[:date]     = Date.parse(curr_data['Date']).to_s
      curr_rate[:rate]     = curr_data['Cur_OfficialRate'] * 10_000
      curr_rate[:mur_id]   = MurmurHash3::V32.str_hash([curr_rate[:currency], curr_rate[:date]].join)

      save_entity(curr_rate)
    end
  end
end
