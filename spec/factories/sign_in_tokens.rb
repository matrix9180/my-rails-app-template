FactoryBot.define do
  factory :sign_in_token do
    association :user
  end
end

