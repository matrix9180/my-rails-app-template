class Settings::TwoFactorAuthentication::RecoveryCodesController < Settings::BaseController
  def index
    if Current.user.recovery_codes.exists?
      @recovery_codes = @user.recovery_codes
    else
      @recovery_codes = @user.recovery_codes.create!(new_recovery_codes)
    end
  end

  def create
    @user.recovery_codes.delete_all
    @user.recovery_codes.create!(new_recovery_codes)

    redirect_to settings_two_factor_authentication_recovery_codes_path, notice: t("two_factor_authentication.profile.recovery_codes.create.new_codes_generated")
  end

  private
    def new_recovery_codes
      10.times.map { { code: new_recovery_code } }
    end

    def new_recovery_code
      SecureRandom.alphanumeric(10).downcase
    end
end
