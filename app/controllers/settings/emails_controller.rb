class Settings::EmailsController < Settings::BaseController
  before_action :require_sudo, only: [ :show, :update ]

  def show
  end

  def update
    # Since we're in sudo mode, the user has already authenticated
    # We can update email without password_challenge
    if @user.update(user_params)
      redirect_to_settings
    else
      render :show, status: :unprocessable_content
    end
  end

  private
    def user_params
      params.permit(:email)
    end

    def redirect_to_settings
      if @user.email_previously_changed?
        resend_email_verification
        redirect_to settings_email_path, notice: t("emails.update.email_changed")
      else
        redirect_to settings_email_path
      end
    end

    def resend_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
