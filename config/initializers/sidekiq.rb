schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?

  Dir[Rails.root.join('app', 'workers', '*.rb')].each { |file| require file }

  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
