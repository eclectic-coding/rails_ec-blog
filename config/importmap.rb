# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# Explicitly pin flash controller (sometimes missed by pin_all_from/hot-reload)
pin "controllers/flash_controller", to: "controllers/flash_controller.js"
pin "@popperjs/core", to: "popper.js"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@rails/activestorage", to: "activestorage.esm.js"

# syntax_highlight is no longer pinned; the Stimulus controller imports the asset path directly.
