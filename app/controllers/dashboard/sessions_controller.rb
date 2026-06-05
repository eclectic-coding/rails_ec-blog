module Dashboard
  class SessionsController < Dashboard::BaseController
    def index
      @pagy, @sessions = pagy(Session.includes(:user).order(created_at: :desc))
    end

    def destroy
      session = Session.find(params.require(:id))
      session.destroy!
      redirect_to dashboard_sessions_path, notice: "Session revoked.", status: :see_other
    end
  end
end
