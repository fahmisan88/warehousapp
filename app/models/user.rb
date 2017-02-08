class User < ApplicationRecord
  has_secure_password

  has_many :wallets
  has_many :parcels
  has_many :shipments

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[a-zA-Z ]+\z/
  VALID_PASSWORD_REGEX = /\A[\w]+\z/
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "Not a valid email address" }
  validates :password, presence: true, on: :create, length: { in: 6..20 }, format: { with: VALID_PASSWORD_REGEX, message: "Only allows alphanumeric and underscore between 6 to 20 characters"}
  validates :package, presence: true, inclusion: { in: [1,2,3] }
  validates :name, presence: true, length: { in: 5..40 }, format: { with: VALID_NAME_REGEX, message: "Only allows letters and space between 5 to 40 characters"}
  enum role: [:user, :staff, :admin]
  enum status: [:Inactive, :Active, :Suspended, :Blocked]

  def self.search(search)
    where("ezi_id ILIKE ?", "%#{search}%")
  end

  def self.search1(search1)
    where("email ILIKE ?", "%#{search1}%")
  end

end
