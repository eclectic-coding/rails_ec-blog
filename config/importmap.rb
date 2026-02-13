# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# Use Bootstrap bundle from CDN - includes Popper internally without separate imports
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"
pin "@rails/activestorage", to: "activestorage.esm.js"

# syntax_highlight is no longer pinned; the Stimulus controller imports the asset path directly.
