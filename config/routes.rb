Rails.application.routes.draw do
  begin
    #if Sequel::Model.db.table_exists?(:users)
      devise_for :users
    #end
  rescue Exception => e
    Rails.logger.error e.inspect.red
  end

  get 'dashboard', to: 'dashboard#index'

  resources :estate, controller: :estate, only: [:index]
  resources :articles

  root 'dashboard#index'
end
