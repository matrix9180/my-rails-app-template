# == Schema Information
#
# Table name: sign_in_tokens
#
#  id      :integer          not null, primary key
#  user_id :integer          not null
#
# Indexes
#
#  index_sign_in_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
FactoryBot.define do
  factory :sign_in_token do
    association :user
  end
end
