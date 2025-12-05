class Admin::Users::AvatarsController < Admin::BaseController
  before_action :set_user

  def show
    # This will show a larger view of the avatar
  end

  def destroy
    @user.avatar.purge if @user.avatar.attached?
    redirect_to admin_user_path(@user), notice: t("admin.users.avatars.destroy.avatar_deleted")
  end

  private
    def set_user
      @user = User.find_by!(username: params[:user_id]&.downcase)
    end
end
