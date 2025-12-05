class Admin::Users::SessionsController < Admin::BaseController
  before_action :set_user
  before_action :set_session, only: :destroy

  def index
    @sessions = @user.sessions.order(created_at: :desc)
  end

  def destroy
    @session.destroy
    redirect_to admin_user_sessions_path(@user), notice: t("admin.users.sessions.destroy.session_logged_out")
  end

  def destroy_all
    @user.sessions.destroy_all
    redirect_to admin_user_sessions_path(@user), notice: t("admin.users.sessions.destroy_all.all_sessions_logged_out")
  end

  private
    def set_user
      @user = User.find_by!(username: params[:user_id]&.downcase)
    end

    def set_session
      @session = @user.sessions.find(params[:id])
    end
end
