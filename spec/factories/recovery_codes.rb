FactoryBot.define do
  factory :recovery_code do
    association :user
    code { SecureRandom.alphanumeric(10).downcase }
    used { false }
  end
end

