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
      if article.save(validate: false)
        puts "  [OK] ##{article.id} → #{article.slug}"
        success += 1
      else
        puts "  [FAIL] ##{article.id} \"#{article.title}\": #{article.errors.full_messages.join(', ')}"
        failed << article.id
      end
    end

    puts "\nDone. #{success} slug(s) generated."
    puts "#{failed.size} article(s) failed: IDs #{failed.join(', ')}" if failed.any?
  end
end

