class Settings::EventsController < ApplicationController
  layout "settings"
  def index
    @events = Current.user.events.order(created_at: :desc)
  end
end

