class Settings::AppearancesController < Settings::BaseController
  def show
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to settings_appearance_path, notice: t("settings.appearance.update.theme_updated") }
        format.json { render json: { status: "success", theme: @user.theme } }
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_content }
        format.json { render json: { status: "error", errors: @user.errors.full_messages }, status: :unprocessable_content }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:theme)
    end
end
