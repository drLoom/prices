Rails.application.routes.draw do
  begin
    #if Sequel::Model.db.table_exists?(:users)
      devise_for :users
    #end
  rescue Exception => e
    Rails.logger.error e.inspect.red
  end

  get 'dashboard', to: 'dashboard#index'

  resources :estate, controller: :estate, only: [:index, :show]
  resources :articles

  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  # constraint = lambda do |request| request.env["warden"].authenticate? and
  #   (request.env['warden'].user.admin? or request.env['warden'].user.monitor?)
  # end

#  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
#  end

  root 'dashboard#index'
end
