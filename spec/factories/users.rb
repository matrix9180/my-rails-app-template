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
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { SecureRandom.alphanumeric(20) + "!@#" }
    verified { true }
  end
end
