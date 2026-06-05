class TestSignInController < ApplicationController
  allow_unauthenticated_access

  def create
    raise "TestSignInController is only available in test environment" unless Rails.env.test?

    user = User.find(params[:user_id])
    start_new_session_for user
    redirect_to dashboard_root_path
  end
end
