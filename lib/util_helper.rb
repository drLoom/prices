# require 'yaml'
#
# module UtilHelper
#   def folder_by_date(time)
#     time.strftime('%Y-%m-%d')
#   end
#
#   def get_data_files(folder, shop_id)
#     [Rails.root.join('data', shop_id, folder, "#{shop_id}.yaml")]
#   end
#
#   def get_files_by_time(time, shop_id)
#     get_data_files(folder_name(time), shop_id)
#   end
#
#   def get_todays_files(shop_id)
#     get_files_by_time(Time.now, shop_id)
#   end
#
#   def get_data_from_files(data_files)
#     data_files.map { |file| get_data_from_file(file) }.flatten!
#   end
#
#   def get_data_from_file(file)
#     File.read(file).split(/---/).map { |chunk| YAML.load(chunk.strip) }.reject { |prod| prod == false }
#   end
#
#   def get_all_collected_dates(shop_id)
#     path = Rails.root.join('data', shop_id)
#     Dir.glob("#{path}/*").map!{|folder_path| folder_path[/data\/\d+\/(.*)$/, 1] }.sort
#   end
#
#   def products_for_shop_by_date(date, shop_id)
#     files = get_data_files(date, shop_id.to_s)
#     get_data_from_files(files)
#   end
# end
