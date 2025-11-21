FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { SecureRandom.alphanumeric(20) + "!@#" }
    verified { true }
  end
end

