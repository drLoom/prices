require 'mechanize'

require_relative 'bloomberg'
require_relative 'economist'

class Articles::Article
  include ActiveModel::Model
  include ActiveModel::Validations

  ARCTICLES_FOLDER = '/data/articles'
  FileUtils.mkdir_p ARCTICLES_FOLDER unless Dir.exist?(ARCTICLES_FOLDER)

  attr_accessor :url, :date, :domain, :name, :file

  class << self
    def all
      Dir.glob("#{ARCTICLES_FOLDER}/*.html").map { |f| article_from_file(f) }
    end

    def article_from_file(file)
      date, domain, name = file.split('/').last.split('@')
      Articles::Article.new(date: date, domain: domain, name: name, file: file)
    end

    def find(name)
      article_from_file(Dir.glob("#{ARCTICLES_FOLDER}/*#{name}*").first)
    end
  end

  def initialize(opts = {})
    @url = opts[:url]

    @date   = opts[:date]
    @domain = opts[:domain]
    @name   = opts[:name]
    @file   = opts[:file]
  end

  def save
    uri          = URI.parse(url)
    article_name = url.to_s.split('/').last
    domain       = uri.host[/(www\.)?(.*)/, 2]

    agent            = Mechanize.new
    agent.log        = Rails.logger
    agent.user_agent = user_agent

    headers = case domain
              when /bloomberg/
                Articles::Bloomberg.headers
              when /economist/
                Articles::Economist.headers
              end

    page = agent.get(uri, [], nil, headers)
    save_page(page.body, domain, article_name)
  end

  def save_page(article_body, domain, article_name)
    File.open(File.join(ARCTICLES_FOLDER, file_name(domain, article_name)), 'wb') { |file| file.write(article_body) }
  end

  def file_name(domain, article_name)
    "#{Date.today.to_s(:db)}@#{domain}@#{article_name}.html"
  end

  def user_agent
    ['Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36'].shuffle.first
  end

  def html
    File.read(file)
  end
end
