class RubygemsImportService
  Result = Data.define(:gems_found, :imported, :skipped)

  def self.call = new.call

  def call
    gems = RubygemsService.gems
    return Result.new(gems_found: false, imported: 0, skipped: 0) if gems.empty?

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

    Result.new(gems_found: true, imported: imported, skipped: skipped)
  end
end
