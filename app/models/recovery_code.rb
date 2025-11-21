# == Schema Information
#
# Table name: recovery_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  used       :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_recovery_codes_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class RecoveryCode < ApplicationRecord
  belongs_to :user
end
