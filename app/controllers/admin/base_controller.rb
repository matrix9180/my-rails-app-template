class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_admin
  before_action :require_sudo
end
