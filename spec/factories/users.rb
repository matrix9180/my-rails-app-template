FactoryBot.define do
  factory :user do
    email { "lazaronixon@hotmail.com" }
    password { "Secret1*3*5*" }
    verified { true }
  end
end

