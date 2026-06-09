require "net/http"
require "json"

class ProjectSyncJob < ApplicationJob
  queue_as :default

  RUBYGEMS_GEM_URL = "https://rubygems.org/api/v1/gems/%s.json"

  def perform
    Project.where.not(rubygem_name: nil).find_each do |project|
      sync_gem(project)
    end
  end

  private

  def sync_gem(project)
    url      = URI(format(RUBYGEMS_GEM_URL, project.rubygem_name))
    response = Net::HTTP.get_response(url)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("[ProjectSyncJob] #{project.rubygem_name}: HTTP #{response.code}")
      return
    end

    data = JSON.parse(response.body)
    project.update!(
      version:        data["version"],
      description:    data["info"],
      last_synced_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("[ProjectSyncJob] #{project.rubygem_name}: #{e.class} — #{e.message}")
  end
end
