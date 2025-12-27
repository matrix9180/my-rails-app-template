class Identity::PasswordResetsController < ApplicationController
  skip_before_action :require_authentication

  rate_limit to: 10, within: 1.hour, only: :create, with: -> { redirect_to root_path, alert: t("common.try_again_later") }
  before_action :set_user, only: %i[ edit update ]

  def new
  end

  def edit
  end

  def create
    if @user = User.find_by(email: params[:email], verified: true)
      send_password_reset_email
      redirect_to sign_in_path, notice: t("password_resets.create.check_email")
    else
      redirect_to new_identity_password_reset_path, alert: t("password_resets.create.must_verify_email")
    end
  end

  def update
    if @user.update(user_params)
      redirect_to sign_in_path, notice: t("password_resets.update.password_reset_successfully")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = User.find_by_token_for!(:password_reset, params[:sid])
    rescue StandardError
      redirect_to new_identity_password_reset_path, alert: t("password_resets.update.invalid_link")
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end

    def send_password_reset_email
      UserMailer.with(user: @user).password_reset.deliver_later
    end
end
