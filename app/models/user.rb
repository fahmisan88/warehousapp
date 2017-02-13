class User < ApplicationRecord
  has_secure_password

  has_many :wallets
  has_many :parcels
  has_many :shipments

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[a-zA-Z ]+\z/
  VALID_PASSWORD_REGEX = /\A[\w]+\z/
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "Not a valid email address" }, unless: :skip_email_validation
  validates :password, presence: true, on: :create, length: { in: 6..20 }, format: { with: VALID_PASSWORD_REGEX, message: "Only allows alphanumeric and underscore between 6 to 20 characters"}, unless: :skip_password_validation
  validates :package, presence: true, inclusion: { in: [1,2,3] }, unless: :skip_package_validation
  validates :name, presence: true, length: { in: 5..40 }, format: { with: VALID_NAME_REGEX, message: "Only allows letters and space between 5 to 40 characters"}, unless: :skip_name_validation
  enum role: [:user, :staff, :admin]
  enum status: [:Inactive, :Active, :Suspended, :Blocked]

  def self.search(search)
    where("ezi_id ILIKE ?", "%#{search}%")
  end

  def self.search1(search1)
    where("email ILIKE ?", "%#{search1}%")
  end

  # token for password reset
  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now
    save!
  end

  # check token validation time. valid if current time is below 4 hrs
  def password_token_valid?
    (self.reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end

  private

  def generate_token
    SecureRandom.hex(10)
  end

end
