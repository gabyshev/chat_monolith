class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :conversations, foreign_key: :sender_id

  validates_uniqueness_of :email
end
