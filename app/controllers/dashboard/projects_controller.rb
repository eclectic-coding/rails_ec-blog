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

    def import_rubygems
      gems = RubygemsService.gems

      if gems.empty?
        redirect_to dashboard_projects_path, alert: "No gems returned from RubyGems — check credentials."
        return
      end

      imported = 0
      skipped  = 0

      gems.each do |gem|
        rubygem_name = gem["name"].presence
        next unless rubygem_name

        if Project.exists?(rubygem_name: rubygem_name)
          skipped += 1
          next
        end

        source_url = gem["homepage_uri"]
        source_url = nil unless source_url&.match?(Project::SAFE_URL_PATTERN)

        Project.create!(
          name:         rubygem_name,
          description:  gem["info"],
          url:          gem["project_uri"],
          source_url:   source_url,
          version:      gem["version"],
          rubygem_name: rubygem_name,
          project_type: "rubygem"
        )
        imported += 1
      end

      notice = build_import_notice(imported, skipped)
      redirect_to dashboard_projects_path, notice: notice
    end

    private

    def build_import_notice(imported, skipped)
      parts = []
      parts << "#{imported} #{"gem".pluralize(imported)} imported" if imported > 0
      parts << "#{skipped} already #{"existed".pluralize(skipped)}" if skipped > 0
      parts.present? ? parts.join(", ") + "." : "Nothing to import."
    end

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
