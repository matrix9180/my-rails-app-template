class Settings::SessionsController < Settings::BaseController
  before_action :set_session, only: :destroy

  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end

  def destroy
    @session.destroy
    redirect_to settings_sessions_path, notice: t("sessions.destroy.session_logged_out")
  end

  private
    def set_session
      @session = Current.user.sessions.find(params[:id])
    end
end
