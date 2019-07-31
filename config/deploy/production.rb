# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

server '167.99.252.151', port: 22, roles: [:web, :app, :db], primary: true

set :application, "prices"
set :repo_url, "git@github.com:drLoom/prices.git"

set :stage,           :production
set :rails_env,       :production

set :projects_path,   fetch(:projects_path, '/home/deploy/apps')

set :user,            'deploy'
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

set :linked_files, %w{config/database.yml config/clickhouse.yml}

set :linked_dirs,    ['log']

set :pty,             true
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "#{fetch(:projects_path)}/#{fetch(:application)}"

set :rvm_ruby_version, 'ruby-2.6.3'

set :puma_threads,    [4, 16]
set :puma_workers,    0
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_rackup,     -> { File.join(current_path, 'config.ru') }
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_conf,       "#{shared_path}/puma.rb"
set :puma_role,       :app
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false
set :puma_env, fetch(:rails_env)

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
