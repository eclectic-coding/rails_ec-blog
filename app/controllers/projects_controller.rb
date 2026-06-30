class ProjectsController < ApplicationController
  allow_unauthenticated_access

  def index
    @pagy, @projects = pagy(Project.includes(:article).featured_first)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
