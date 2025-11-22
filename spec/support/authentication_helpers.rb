module AuthenticationHelpers
  def sign_in_as(user)
    post(sign_in_url, params: { email: user.email, password: user.password })
    user
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.include ActiveSupport::Testing::TimeHelpers
end
