class SettingsController < ApplicationController
  layout "settings"

  def index
    redirect_to settings_profile_path
  end
end
