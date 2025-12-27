class Sessions::OmniauthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authentication

  def create
    @user = User.create_with(user_params).find_or_initialize_by(omniauth_params)

    if @user.save
      session_record = @user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      redirect_to root_path, notice: "Signed in successfully"
    else
      redirect_to sign_in_path, alert: "Authentication failed"
    end
  end

  def failure
    redirect_to sign_in_path, alert: params[:message]
  end

  private
    def user_params
      {
        email: omniauth.info.email,
        username: generate_unique_username(omniauth.info.email),
        password: SecureRandom.base58,
        verified: true
      }
    end

    def generate_unique_username(email)
      base_username = email.split("@").first.gsub(/[^a-zA-Z0-9]/, "").downcase
      base_username = "user" if base_username.empty?

      username = base_username
      counter = 1
      while User.exists?(username: username)
        username = "#{base_username}#{counter}"
        counter += 1
      end
      username
    end

    def omniauth_params
      { provider: omniauth.provider, uid: omniauth.uid }
    end

    def omniauth
      request.env["omniauth.auth"]
    end
end
