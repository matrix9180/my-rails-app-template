class Settings::EventsController < Settings::BaseController
  def index
    @events = Current.user.events.order(created_at: :desc).page(params[:page]).per(25)
  end
end
