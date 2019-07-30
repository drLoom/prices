require 'uri'
require 'yaml'
require 'murmurhash3'
require 'awesome_print'
require 'fileutils'

require_relative '../data_storage'
require_relative 'crawler'
require_relative 'validators/validator_factory'
require_relative 'validators/macro_validator_factory'

class ParserBase
  attr_reader :domain, :validators, :proxies

  class << self
    def crawler_options
      @crawler_options ||= {}
    end

    def debug_mode(flag = false)
      crawler_options[:debug] = flag
    end

    def start_urls(urls)
      crawler_options[:start_urls] = urls.is_a?(Array) ? urls : [urls]
    end

    def domain(domain)
      crawler_options[:domain] = domain
    end

    def validator(*arguments)
      @validators ||= []
      @validators << ValidatorFactory.create_validator(arguments)
    end

    def validators
      @validators
    end

    def macro_validator(*arguments)
      @macro_validator_configs ||= {}
      @macro_validator_configs[arguments.first] ||= []
      @macro_validator_configs[arguments.first] << arguments
    end

    def macro_validator_configs
      @macro_validator_configs
    end
  end

  def initialize(opts = {})
    @validators = self.class.validators ? self.class.validators.map(&:dup) : []

    @domain = self.class.crawler_options[:domain]
    @proxies = opts[:proxies]
  end

  def start
    self.class.crawler_options[:start_urls].each do |url|
      yield({ url: url, method: :get, params: {}, data: {}, callback: :parse })
    end
  end

  def full_url(url)
    return url if url[/\Ahttp/]

    URI.join(URI.parse(self.class.crawler_options[:start_urls].first), url).to_s rescue url
  end

  def string_to_float(str)
    return str unless str.is_a?(String)
    str.sub(/\s?ру?б?/, '').to_f
  end

  def final_stats
    entities = DataStorage.get_data_from_file(DataStorage.today_entity_path(domain)) if File.exist?(DataStorage.today_entity_path(domain))
    entities ||= []

    doubles = entities.group_by { |entity| entity[:mur_id] }.reject { |_code, group| group.size == 1 }
    total_doubles = doubles.map { |_code, group| group.size }.inject(&:+)
    with_errors = entities.select { |entity| entity[:errors] }

    unless with_errors.empty?
      File.open(today_erros_path, 'w') do |f|
        f.write(with_errors.to_yaml)
      end
    end

    macro_validate(entities)

    puts "Folder: #{DataStorage.today_folder(domain)}".purple
    puts "Downloaded for #{self.class} entitys: #{entities.size}, doubles: #{total_doubles.to_i}, with_errors: #{with_errors.size}".green
  end

  def clear_today_downloaded
    File.delete(DataStorage.today_entity_path(domain)) if File.exist?(DataStorage.today_entity_path(domain))
  end

  def save_product(product)
    product[:domain]       = domain
    product[:collected_at] = Time.now.strftime('%Y-%m-%d')
    product[:price]        = string_to_float(product[:price])
    product[:old_price]    = string_to_float(product[:old_price])

    validate(product)

    File.open(DataStorage.today_entity_path(domain), 'a') do |f|
      f.flock(File::LOCK_EX)
      f.write(product.to_yaml)
    end
  end

  def save_entity(entity)
    entity[:domain] = domain

    entity.each do |key, value|
      next unless value.is_a?(String)
      entity[key] = value.strip
    end

    validate(entity)

    File.open(DataStorage.today_entity_path(domain), 'a') do |f|
      f.flock(File::LOCK_EX)
      f.write(entity.to_yaml)
    end
  end

  def validate(entity)
    validators.each { |validator| validator.validate(entity) } if validators
  end

  def macro_validate(items)
    macro_validator_configs = self.class.macro_validator_configs
    return unless macro_validator_configs

    macro_validators = []
    macro_validator_configs.each do |type, validators|
      type_options = {}
      validators.each do |validator_args|
        _name    = validator_args.shift
        options = validator_args[-1].is_a?(Hash) ? validator_args.pop : {}
        fields  = validator_args

        fields.each do |field|
          type_options[field] = options
        end
      end
      macro_validators << MacroValidatorFactory.create_validator(type, type_options)
    end

    macro_validators.each do |validator|
      validator_result = validator.validate(items)
      unless validator_result[:valid]
        puts "Download stats bad".red
        FileUtils.mv(DataStorage.today_entity_path(domain), File.join(DataStorage.today_folder(domain),"#{domain}_#{validator.class.to_s.downcase}_products.yaml"))
      end

      ap validator_result[:output]
      File.open(File.join(DataStorage.today_folder(domain), "#{domain}_#{validator.class.to_s.downcase}_macro_stats.yaml"), 'w') do |f|
        f.write(validator_result[:output].to_yaml)
      end
    end
  end

  def setup_capybara(opts = {})
    require 'capybara'
    require 'capybara/dsl'
    require 'capybara/poltergeist'

    extend Capybara::DSL

    Capybara.javascript_driver = :poltergeist
    Capybara.default_driver    = :poltergeist
    Capybara.app_host          = opts[:app_host]

    proxy = opts[:proxy]

    phantomjs_options = [
      '--ssl-protocol=any',
      '--load-images=no'
    ]

    phantomjs_options << "--proxy=#{proxy.host}:#{proxy.port}" if proxy

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false, debug: true, timeout: 40, phantomjs_options: phantomjs_options)
    end

    Capybara.current_session.driver.set_proxy(proxy.host, proxy.port) if proxy

    Capybara.current_session
  end
end
