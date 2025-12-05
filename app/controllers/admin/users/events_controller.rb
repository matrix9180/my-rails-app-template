class Admin::Users::EventsController < Admin::BaseController
  before_action :set_user

  def index
    @events = @user.events.order(created_at: :desc).page(params[:page]).per(25)
  end

  private
    def set_user
      @user = User.find_by!(username: params[:user_id]&.downcase)
    end
end
