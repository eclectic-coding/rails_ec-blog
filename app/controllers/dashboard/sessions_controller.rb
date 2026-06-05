module Dashboard
  class SessionsController < Dashboard::BaseController
    def destroy
      session = Session.find(params.require(:id))
      session.destroy!
      redirect_to dashboard_user_path(session.user), notice: "Session revoked.", status: :see_other
    end
  end
end