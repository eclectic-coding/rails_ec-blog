module Dashboard
  module Projects
    class RubygemsImportsController < Dashboard::BaseController
      def create
        result = RubygemsImportService.call

        unless result.gems_found
          redirect_to dashboard_projects_path, alert: "No gems returned from RubyGems — check credentials."
          return
        end

        redirect_to dashboard_projects_path, notice: build_notice(result.imported, result.skipped)
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
