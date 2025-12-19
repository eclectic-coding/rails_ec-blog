class Admin::DashboardController < ApplicationController
  before_action :admin_only!

  def show
  end
end
