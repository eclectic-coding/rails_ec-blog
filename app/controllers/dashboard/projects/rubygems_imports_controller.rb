module Dashboard
  module Projects
    class RubygemsImportsController < Dashboard::BaseController
      def create
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

        redirect_to dashboard_projects_path, notice: build_notice(imported, skipped)
      end

      private

      def build_notice(imported, skipped)
        parts = []
        parts << "#{imported} #{"gem".pluralize(imported)} imported" if imported > 0
        parts << "#{skipped} already #{"existed".pluralize(skipped)}" if skipped > 0
        parts.present? ? parts.join(", ") + "." : "Nothing to import."
      end
    end
  end
end
