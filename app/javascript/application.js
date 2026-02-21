// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"

// Import Bootstrap bundle - it will auto-expose itself as window.bootstrap
import "bootstrap"

ActiveStorage.start()



import "trix"
import "@rails/actiontext"
