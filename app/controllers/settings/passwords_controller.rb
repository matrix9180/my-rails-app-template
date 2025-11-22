class Settings::PasswordsController < ApplicationController
  layout "settings"
  before_action :set_user

  def show
  end

  def update
    if @user.update(user_params)
      redirect_to settings_password_path, notice: t("passwords.update.password_changed")
    else
      render :show, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
    end
end

