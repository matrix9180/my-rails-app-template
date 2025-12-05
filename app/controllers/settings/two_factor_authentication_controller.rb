class Settings::TwoFactorAuthenticationController < Settings::BaseController
  before_action :set_totp, only: %i[ show create ]

  def show
    @qr_code = RQRCode::QRCode.new(provisioning_uri) unless @user.otp_required_for_sign_in?
  end

  def create
    if @totp.verify(params[:code], drift_behind: 15)
      @user.update! otp_required_for_sign_in: true
      redirect_to settings_two_factor_authentication_recovery_codes_path
    else
      redirect_to settings_two_factor_authentication_path, alert: t("two_factor_authentication.profile.totps.create.code_didnt_work")
    end
  end

  def update
    @user.update! otp_secret: ROTP::Base32.random
    redirect_to settings_two_factor_authentication_path
  end

  private
    def set_totp
      @totp = ROTP::TOTP.new(@user.otp_secret, issuer: "YourAppName")
    end

    def provisioning_uri
      @totp.provisioning_uri @user.email
    end
end
