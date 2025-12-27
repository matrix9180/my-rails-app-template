class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details
  before_action :authenticate
  before_action :require_authentication

  private
    def authenticate
      if session_record = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session_record
      end
    end

    def require_authentication
      redirect_to sign_in_path unless Current.session
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

    def set_user
      @user = Current.user
    end

    def require_sudo
      unless Current.session.sudo?
        redirect_to new_sessions_sudo_path(proceed_to_url: request.original_url)
      end
    end

    def require_admin
      if Current.user.blank?
        redirect_to sign_in_path, alert: t("application.require_admin.must_be_signed_in")
      else
        redirect_to root_path, alert: t("application.require_admin.not_authorized") unless Current.user.admin?
      end
    end
end
