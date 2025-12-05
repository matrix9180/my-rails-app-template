class Settings::BaseController < ApplicationController
  layout "settings"
  before_action :set_user
end
