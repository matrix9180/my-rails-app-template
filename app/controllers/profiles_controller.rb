class ProfilesController < ApplicationController
  before_action :set_user
  before_action :require_sudo, only: [ :edit, :update ]

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

  private
    def set_user
      if action_name == "show"
        @user = User.find_by!(username: params[:id]&.downcase)
      else
        @user = Current.user
      end
    end

    def profile_params
      params.require(:user).permit(:avatar, :bio)
    end
end
