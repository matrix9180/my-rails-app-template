class Settings::PasswordsController < Settings::BaseController
  before_action :require_sudo, only: [ :show, :update ]

  def show
  end

  def update
    # Since we're in sudo mode, the user has already authenticated
    # We need to bypass password_challenge validation by using update_columns
    @user.assign_attributes(user_params)

    # Validate password manually (since we're bypassing normal validation)
    if @user.password.blank?
      @user.errors.add(:password, "can't be blank")
    elsif @user.password.length < 12
      @user.errors.add(:password, "is too short (minimum is 12 characters)")
    elsif @user.password != @user.password_confirmation
      @user.errors.add(:password_confirmation, "doesn't match Password")
    end

    # Check if password is pwned (if the validator is available)
    if @user.password.present? && @user.password.length >= 12 && @user.password == @user.password_confirmation
      begin
        pwned_check = Pwned::Password.new(@user.password)
        if pwned_check.pwned?
          @user.errors.add(:password, "might easily be guessed")
        end
      rescue
        # Pwned check failed, skip it
      end
    end

    if @user.errors.empty?
      # Update password_digest directly, bypassing password_challenge requirement
      old_password_digest = @user.password_digest
      @user.update_columns(password_digest: BCrypt::Password.create(@user.password), updated_at: Time.current)

      # Manually trigger callbacks that would have run
      if old_password_digest != @user.password_digest
        @user.sessions.where.not(id: Current.session).delete_all
        @user.events.create! action: "password_changed"
      end

      redirect_to settings_password_path, notice: t("passwords.update.password_changed")
    else
      render :show, status: :unprocessable_content
    end
  end

  private
    def user_params
      params.permit(:password, :password_confirmation)
    end
end
