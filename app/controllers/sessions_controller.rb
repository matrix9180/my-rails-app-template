class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[ new create ]

  def new
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      if user.otp_required_for_sign_in?
        session[:challenge_token] = user.signed_id(purpose: :authentication_challenge, expires_in: 20.minutes)
        redirect_to new_two_factor_authentication_challenge_totp_path
      else
        @session = user.sessions.create!
        cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

        redirect_to root_path, notice: t("sessions.create.signed_in_successfully")
      end
    else
      redirect_to sign_in_path(email_hint: params[:email]), alert: t("sessions.create.incorrect_email_password")
    end
  end
end
