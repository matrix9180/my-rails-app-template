class ProfilesController < ApplicationController
  before_action :set_user
  before_action :require_sudo, only: [ :edit, :update, :update_avatar ]

  def my_profile
    @user = Current.user
    render :show
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to my_profile_path, notice: t("profiles.update.profile_updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def update_avatar
    @user = Current.user
    if @user.update(avatar_params)
      redirect_to edit_my_profile_path, notice: t("profiles.update.avatar_updated")
    else
      redirect_to edit_my_profile_path, alert: t("profiles.update.avatar_update_failed")
    end
  end

  private
    def set_user
      if action_name == "show"
        @user = User.find_by!(username: params[:id]&.downcase)
      else
        @user = Current.user
      end
    end

    def profile_params
      params.require(:user).permit(:bio)
    end

    def avatar_params
      params.require(:user).permit(:avatar)
    end
end
