class User < Sequel::Model
  plugin :devise
  plugin :timestamps, :update_on_create => true

  devise :database_authenticatable, :registerable, :rememberable, :validatable
end
