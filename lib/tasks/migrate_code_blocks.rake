# lib/tasks/migrate_code_blocks.rake
#
# Converts Trix-format code blocks to Lexxy format in all Article ActionText bodies.
#
# Trix stores:  <pre><code class="ruby">…</code></pre>
# Lexxy stores: <pre data-language="ruby">…</pre>
#
# Usage:
#   rails articles:migrate_code_blocks
#   rails articles:migrate_code_blocks DRY_RUN=true   # preview without saving

namespace :articles do
  desc "Migrate Trix <pre><code class=LANG> blocks to Lexxy <pre data-language=LANG> format"
  task migrate_code_blocks: :environment do
    dry_run = ENV["DRY_RUN"] == "true"
    puts dry_run ? "DRY RUN — no changes will be saved\n\n" : ""

    rich_texts = ActionText::RichText.where(name: "content", record_type: "Article")
    migrated = 0
    skipped  = 0

    rich_texts.find_each do |rt|
      body = rt.body_before_type_cast.to_s
      next if body.blank?

      doc = Nokogiri::HTML.fragment(body)

      # Find every <pre> that doesn't already have data-language
      pres = doc.css("pre:not([data-language])")
      next if pres.empty? && (skipped += 1) && false # count skipped below

      if pres.empty?
        skipped += 1
        next
      end

      pres.each do |pre|
        inner_code = pre.at_css("code")

        # Detect language from class="ruby" / class="language-ruby"
        lang = nil
        if inner_code
          klass = inner_code["class"].to_s
          lang = klass.sub(/\Alanguage-/, "").presence
          lang = nil if lang == klass && !lang&.match?(/\A\w[\w-]*\z/)
        end
        lang ||= "plain"

        # Unwrap <code> wrapper — Lexxy puts the text directly inside <pre>
        pre.inner_html = inner_code ? inner_code.inner_html : pre.inner_html
        pre["data-language"] = lang
      end

      new_body = doc.to_html

      if dry_run
        puts "Article ActionText id=#{rt.id} (record_id=#{rt.record_id}) — " \
             "#{pres.size} block(s) → #{pres.map { |p| p['data-language'] }.join(', ')}"
      else
        rt.update_column(:body, new_body)
        print "."
      end

      migrated += 1
    end

    puts "\n\nDone. Migrated: #{migrated}, already up-to-date: #{skipped}"
  end
end

