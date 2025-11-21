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
require "rails_helper"

RSpec.describe SignInToken, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end
end


