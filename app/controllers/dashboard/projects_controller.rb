module Dashboard
  class ProjectsController < Dashboard::BaseController
    before_action :set_project, only: %i[show edit update destroy]

    def index
      @pagy, @projects = pagy(Project.featured_first)
    end

    def show
    end

    def new
      @project = Project.new
    end

    def edit
    end

    def create
      @project = Project.new(project_params)

      if @project.save
        redirect_to dashboard_project_path(@project), notice: "Project was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @project.update(project_params)
        redirect_to dashboard_project_path(@project), notice: "Project was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @project.destroy!
      redirect_to dashboard_projects_path, notice: "Project was successfully deleted.", status: :see_other
    end

    private

    def set_project
      @project = Project.find(params.require(:id))
    end

    def project_params
      params.require(:project).permit(
        :name, :description, :url, :source_url,
        :project_type, :rubygem_name, :version,
        :is_featured, :position
      )
    end
  end
end
