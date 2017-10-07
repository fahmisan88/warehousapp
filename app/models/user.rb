class User < ApplicationRecord
  has_secure_password

  mount_uploader :icpassport, IcpassportUploader

  has_many :wallets
  has_many :parcels
  has_many :shipments

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[a-zA-Z\x27 ]+\z/i
  VALID_PASSWORD_REGEX = /\A[\w]+\z/
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "Not a valid email address" }
  validates :password, presence: true, on: :create, length: { in: 6..20 }, format: { with: VALID_PASSWORD_REGEX, message: "Only allows alphanumeric and underscore between 6 to 20 characters"}

  # package; 1 = RM150/year, 2 = RM250/2years, 3 = RM300/3years
  validates :package, inclusion: { in: [1,2,3] }
  validates :name, presence: true, length: { in: 5..80 }, format: { with: VALID_NAME_REGEX, message: "Only allows letters, space and single quote (') between 5 to 80 characters"}
  validates_file_size :icpassport, in: 500.kilobytes..3.megabytes, message: 'Identity card or passport image size must between %{min} and %{max}'
  validates_file_content_type :icpassport, allow: ['image/jpeg', 'image/jpg', 'image/png'], mode: :strict, message: 'Only %{types} are allowed'

  enum role: [:user, :staff, :admin]
  enum status: [:Inactive, :Active, :Suspended, :Blocked, :Expired]

  def self.search(search)
    where('ezi_id ILIKE :search OR email ILIKE :search', search: "%#{search}%")
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
