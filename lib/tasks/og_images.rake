namespace :og_images do
  desc "Generate OG social card images for published articles missing one (FORCE=true to regenerate all)"
  task generate: :environment do
    force = ENV["FORCE"] == "true"

    scope = Article.published.with_attached_image
    scope = scope.where.missing(:og_image_attachment) unless force

    total = scope.count

    if total.zero?
      puts force ? "Nothing to do — all published articles already have OG images." \
                 : "Nothing to do — no published articles are missing OG images. Use FORCE=true to regenerate all."
      next
    end

    puts force ? "Regenerating OG images for all #{total} published article(s)..." \
               : "Generating OG images for #{total} published article(s) missing a card..."

    success = 0
    failed  = []

    scope.find_each do |article|
      begin
        OgImageGenerationJob.perform_now(article.id)
      rescue => e
        Rails.logger.warn("[og_images:generate] article=#{article.id}: #{e.class}: #{e.message}")
      end

      if article.reload.og_image.attached?
        puts "  [OK] ##{article.id} → #{article.slug}"
        success += 1
      else
        puts "  [FAIL] ##{article.id} #{article.slug}: OG image was not attached"
        failed << article.id
      end
    end

    puts "\nDone. #{success} OG image(s) generated."
    puts "#{failed.size} article(s) failed: IDs #{failed.join(', ')}" if failed.any?
  end
end