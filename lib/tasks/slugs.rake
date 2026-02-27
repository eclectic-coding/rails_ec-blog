namespace :slugs do
  desc "Backfill FriendlyId slugs for articles that are missing one"
  task backfill_articles: :environment do
    scope = Article.where(slug: nil)
    total = scope.count

    if total.zero?
      puts "All articles already have slugs. Nothing to do."
      next
    end

    puts "Backfilling slugs for #{total} article(s)..."

    success = 0
    failed  = []

    scope.find_each do |article|
      article.slug = nil           # force FriendlyId to (re)generate

      # Run validations to trigger FriendlyId callbacks (slug generation) without persisting yet
      article.valid?

      if article.slug.blank?
        puts "  [FAIL] ##{article.id} \"#{article.title}\": slug could not be generated"
        failed << article.id
        next
      end

      begin
        if article.save(validate: false)
          puts "  [OK] ##{article.id} → #{article.slug}"
          success += 1
        else
          puts "  [FAIL] ##{article.id} \"#{article.title}\": #{article.errors.full_messages.join(', ')}"
          failed << article.id
        end
      rescue ActiveRecord::RecordNotUnique => e
        puts "  [FAIL] ##{article.id} \"#{article.title}\": slug uniqueness violation (#{e.class}: #{e.message})"
        failed << article.id
      rescue StandardError => e
        puts "  [FAIL] ##{article.id} \"#{article.title}\": unexpected error while saving (#{e.class}: #{e.message})"
        failed << article.id
      end
    end

    puts "\nDone. #{success} slug(s) generated."
    puts "#{failed.size} article(s) failed: IDs #{failed.join(', ')}" if failed.any?
  end
end

