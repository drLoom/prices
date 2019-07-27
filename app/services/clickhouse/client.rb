require 'clickhouse'
require 'yaml'

require_relative 'clickhouse_ext'

module Clickhouse
  class Client
    @@connection = nil

    # { host: '', port: 12345, username: '', password: '' }
    # path to config
    # or default path 'configs/clickhouse.yaml'
    def self.conn(cfg = nil)
      return @@connection if @@connection

      Clickhouse.logger ||= Logger.new(STDOUT)

      case cfg
      when String
        config_path = cfg
      when Hash
        config = cfg
      else
        config_path = default_config_path
      end

      config ||= YAML.load(File.read(config_path))[Rails.env]

      Clickhouse.establish_connection(config)

      @@connection = Clickhouse.connection
    end

    def self.default_config_path
      Rails.root.join('config', 'clickhouse.yml')
    end
  end
end
