# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string           not null
#  otp_required_for_sign_in :boolean          default(FALSE), not null
#  otp_secret               :string           not null
#  password_digest          :string           not null
#  provider                 :string
#  role                     :integer          default(0), not null
#  theme                    :integer          default("light"), not null
#  uid                      :string
#  username                 :string
#  verified                 :boolean          default(FALSE), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
class User < ApplicationRecord
  has_secure_password

  enum :role, {
    user: 0,
    admin: 1_000
    # App-specific roles here
  }

  enum :theme, {
    light: 0,
    dark: 1,
    cupcake: 2,
    bumblebee: 3,
    emerald: 4,
    corporate: 5,
    synthwave: 6,
    retro: 7,
    cyberpunk: 8,
    valentine: 9,
    halloween: 10,
    garden: 11,
    forest: 12,
    aqua: 13,
    lofi: 14,
    pastel: 15,
    fantasy: 16,
    wireframe: 17,
    black: 18,
    luxury: 19,
    dracula: 20,
    cmyk: 21,
    autumn: 22,
    business: 23,
    acid: 24,
    lemonade: 25,
    night: 26,
    coffee: 27,
    winter: 28,
    dim: 29,
    nord: 30,
    sunset: 31,
    caramellatte: 32,
    abyss: 33,
    silk: 34
  }

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end


  has_many :sessions, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy
  has_many :sign_in_tokens, dependent: :destroy
  has_many :events, dependent: :destroy

  has_one_attached :avatar
  has_rich_text :bio

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: ->(object, data) { I18n.t("errors.username.invalid_format") } }
  validates :password, allow_nil: true, length: { minimum: 12 }
  validates :password, not_pwned: { message: -> { I18n.t("errors.password.pwned") } }

  normalizes :email, with: -> { _1.strip.downcase }
  normalizes :username, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_validation on: :create do
    self.otp_secret = ROTP::Base32.random
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_update if: :email_previously_changed? do
    events.create! action: "email_verification_requested"
  end

  after_update if: :password_digest_previously_changed? do
    events.create! action: "password_changed"
  end

  after_update if: [ :verified_previously_changed?, :verified? ] do
    events.create! action: "email_verified"
  end

  def to_param
    username
  end
end
