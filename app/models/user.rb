class User < ApplicationRecord
  has_secure_password

  has_many :wallets
  has_many :parcels
  has_many :shipments

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 6 }

  validates :name, presence: true, length: { maximum: 30 }
  enum role: [:user, :staff, :admin]

end
