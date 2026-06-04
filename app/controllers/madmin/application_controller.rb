module Madmin
  class ApplicationController < Madmin::BaseController
    include Authentication

    before_action :require_admin!

    private

    def require_admin!
      redirect_to root_path, alert: "Not authorized." unless admin?
    end
  end
end
