class Sessions::PasswordlessesController < ApplicationController
  skip_before_action :require_authentication

  rate_limit to: 10, within: 1.hour, only: :create, with: -> { redirect_to root_path, alert: t("common.try_again_later") }
  before_action :set_user, only: :edit

  def new
  end

  def edit
    session_record = @user.sessions.create!
    cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

    revoke_tokens; redirect_to(root_path, notice: t("passwordlesses.edit.signed_in_successfully"))
  end

  def create
    if @user = User.find_by(email: params[:email], verified: true)
      send_passwordless_email
      redirect_to sign_in_path, notice: t("passwordlesses.create.check_email")
    else
      redirect_to new_sessions_passwordless_path, alert: t("passwordlesses.create.must_verify_email")
    end
  end

  private
    def set_user
      token = SignInToken.find_signed!(params[:sid]); @user = token.user
    rescue StandardError
      redirect_to new_sessions_passwordless_path, alert: t("passwordlesses.create.invalid_link")
    end

    def send_passwordless_email
      UserMailer.with(user: @user).passwordless.deliver_later
    end

    def revoke_tokens
      @user.sign_in_tokens.delete_all
    end
end
