source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 6.0.0.rc2'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'

gem 'bootsnap', '>= 1.4.2', require: false

gem 'pg', '~> 1.1.4'
gem 'sequel', '~> 5.22'
gem 'sequel-rails', '~> 1.0'
gem 'clickhouse', '~> 0.1.10'
gem 'bootstrap', '~> 4.3.1'

gem 'trollop', '~> 2.9.9'
gem 'httparty', '~> 0.17.0'
gem 'murmurhash3', '~> 0.1.6'
gem 'awesome_print', '~> 1.8.0'
gem 'colorize', '~> 0.8.1'
gem 'capybara', '~> 3.26.0'
gem 'poltergeist', '~> 1.18.1'
gem 'concurrent-ruby', '~> 1.1.5'

gem 'devise', '~> 4.6.2'
gem 'sequel-devise', '~> 0.0.13'
gem 'sequel-devise-generators'
gem 'slim-rails', '~> 3.2'
gem 'mechanize'
gem 'sidekiq'
gem 'sidekiq-cron'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano', '~> 3.11.0',         require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-linked-files', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rvm',     require: false
  gem 'sshkit-sudo',        require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
