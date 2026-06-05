module Dashboard
  class BaseController < ApplicationController
    layout "dashboard"

    before_action :admin_only!
  end
end
