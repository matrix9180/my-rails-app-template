class Settings::ProfilesController < ApplicationController
  layout "settings"
  before_action :set_user
  before_action :require_sudo, only: [ :show, :update ]

  def show
  end

  def update
    if @user.update(profile_params)
      redirect_to settings_profile_path, notice: t("profiles.update.profile_updated")
    else
      render :show, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def profile_params
      params.require(:user).permit(:avatar, :bio)
    end
end

