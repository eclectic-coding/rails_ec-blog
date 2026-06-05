module Dashboard
  class UsersController < Dashboard::BaseController
    before_action :set_user, only: %i[show edit update]

    def index
      @pagy, @users = pagy(User.order(:email_address))
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to dashboard_user_path(@user), notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params.require(:id))
    end

    def user_params
      permitted = params.require(:user).permit(:email_address, :admin, :password, :password_confirmation)
      permitted.delete(:password) if permitted[:password].blank?
      permitted.delete(:password_confirmation) if permitted[:password_confirmation].blank?
      permitted
    end
  end
end
