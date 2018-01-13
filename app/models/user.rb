class User < ApplicationRecord
  has_secure_password

  mount_uploader :icpassport, IcpassportUploader

  attr_accessor :skip_icpassport_validation
  attr_accessor :skip_package_validation
  attr_accessor :skip_password_validation
  attr_accessor :skip_name_validation
  attr_accessor :skip_phone_validation

  has_many :wallets
  has_many :parcels
  has_many :shipments

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[a-zA-Z\x27\x2d\x40 ]+\z/i
  VALID_PASSWORD_REGEX = /\A[\w]+\z/
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "Not a valid email address" }
  validates :password, presence: true, on: :create, length: { in: 6..20 }, format: { with: VALID_PASSWORD_REGEX, message: "Only allows alphanumeric and underscore between 6 to 20 characters"}, unless: :skip_password_validation

  # package; 1 = RM150/year, 2 = RM250/2years, 3 = RM300/3years
  validates :package, inclusion: { in: [1,2] }, unless: :skip_package_validation
  validates :name, presence: true, length: { in: 5..80 }, format: { with: VALID_NAME_REGEX, message: "Only letters, space, single quote ('), hyphen (-) and alias (@) are allowed between 5 to 80 characters"}, unless: :skip_name_validation

  # validates_file_size :icpassport, in: 500.kilobytes..3.megabytes, message: 'Identity card or passport image size must between %{min} and %{max}'
  # validates_file_content_type :icpassport, allow: ['image/jpeg', 'image/jpg', 'image/png'], mode: :strict, message: 'Only %{types} are allowed'

  validates :icpassport, presence: true, file_size: { less_than: 3.megabytes, message: 'Identity card or passport image size must below 3MB' }, file_content_type: { allow: ['image/jpeg', 'image/png', 'image/jpg'], mode: :strict, message: 'Only %{types} are allowed' }, unless: :skip_icpassport_validation

  validates :phone, phone: {types: :mobile}, unless: :skip_phone_validation

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
