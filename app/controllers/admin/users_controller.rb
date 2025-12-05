class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.all.order(created_at: :desc)

    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where("LOWER(username) LIKE ? OR LOWER(email) LIKE ?", search_term.downcase, search_term.downcase)
    end

    # Filter by role
    if params[:role].present?
      @users = @users.where(role: params[:role])
    end

    # Pagination
    @users = @users.page(params[:page]).per(25)
  end

  def show
  end

  def edit
  end

  def update
    params_to_use = user_params
    # Prevent current user from changing their own role
    if @user == Current.user
      params_to_use = params_to_use.except(:role)
    end

    if @user.update(params_to_use)
      redirect_to admin_user_path(@user), notice: t("admin.users.update.user_updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @user == Current.user
      redirect_to admin_users_path, alert: t("admin.users.destroy.cannot_delete_self")
    else
      @user.destroy
      redirect_to admin_users_path, notice: t("admin.users.destroy.user_deleted")
    end
  end

  private
    def set_user
      @user = User.find_by!(username: params[:id]&.downcase)
    end

    def user_params
      params.require(:user).permit(:email, :username, :role, :verified)
    end
end
