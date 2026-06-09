class ProjectsController < ApplicationController
  allow_unauthenticated_access

  def index
    @projects = Project.featured_first
  end
end
