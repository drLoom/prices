require 'yaml'

module DataStorage
  DATA_DIR = '/data/prices'

  module_function

  def domain_folder(domain)
    File.join(DATA_DIR, domain)
  end

  def get_data_from_file(file)
    File.read(file).split(/---/).reject(&:blank?).map { |chunk| YAML.load(chunk.strip) }
  end

  def today_entity_path(domain)
    File.join(today_folder(domain),"#{domain}.yaml")
  end

  def today_erros_path(domain)
    File.join(today_folder(domain), "#{domain}_errors.yaml")
  end

  def today_folder(domain)
    folder = File.join(DataStorage.domain_folder(domain), Time.now.utc.strftime('%Y-%m-%d'))

    FileUtils.mkdir_p folder
    folder
  end
end
