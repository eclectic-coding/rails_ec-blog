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
      OgImageGenerationJob.perform_now(article.id)
      puts "  [OK] ##{article.id} → #{article.slug}"
      success += 1
    rescue => e
      puts "  [FAIL] ##{article.id} #{article.slug}: #{e.class}: #{e.message}"
      failed << article.id
    end

    puts "\nDone. #{success} OG image(s) generated."
    puts "#{failed.size} article(s) failed: IDs #{failed.join(', ')}" if failed.any?
  end
end