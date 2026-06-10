# EclecticCoding Blog

[![CI](https://github.com/eclectic-coding/rails_ec-blog/actions/workflows/ci.yml/badge.svg)](https://github.com/eclectic-coding/rails_ec-blog/actions/workflows/ci.yml)
[![Ruby](https://img.shields.io/badge/ruby-4.0.5-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.1-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![Bootstrap](https://img.shields.io/badge/bootstrap-5.3-7952B3?logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
[![codecov](https://codecov.io/gh/eclectic-coding/rails_ec-blog/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/rails_ec-blog)

A personal blog built with Rails 8.1, Hotwire, and Bootstrap 5. Articles support rich text via Trix, cover image uploads via Active Storage, and tagging. The admin dashboard lives at `/admin`.

## Tech Stack

- **Ruby 4.0.5 / Rails 8.1** — SQLite in development/test
- **Hotwire** (Turbo + Stimulus) for reactive UI
- **Bootstrap 5.3** + Dart Sass via `dartsass-rails`
- **Propshaft** asset pipeline with importmap (no Webpack/esbuild)
- **Action Text** (Trix editor) + **Active Storage** for rich content and image uploads
- **Pagy** for pagination
- **FriendlyId** for slug-based article URLs
- **RSpec** + **FactoryBot** + **SimpleCov** for testing

## Getting Started

```bash
# Install dependencies
bundle install

# Set up the database
bin/rails db:create db:migrate db:seed

# Start the development server (Rails + Dart Sass watcher)
bin/dev
```

The app runs at `http://localhost:3000`.

Seeds create sample articles and tags. They expect `User.find(1)` to exist — create an admin user first:

```bash
bin/rails console
User.create!(email_address: "you@example.com", password: "password", admin: true)
```

## Admin Dashboard

The dashboard is available at `/admin` and requires an admin user. It provides full CRUD for articles, tags, users, and sessions.

## Commands

```bash
# Run all tests
bin/rspec

# Run a single spec file
bin/rspec spec/models/article_spec.rb

# Run by line number
bin/rspec spec/models/article_spec.rb:42

# Lint
bin/rubocop
bin/rubocop -a        # auto-correct safe offenses

# Security scans
bin/brakeman --no-pager
bin/bundler-audit

# Pre-push gate (rspec + brakeman + bundle-audit + rubocop)
bin/cleanup

# Database
bin/rails db:migrate
bin/rails db:test:prepare
bin/rails db:seed
```

## Testing

```bash
bin/rspec          # full suite
bin/cleanup        # full gate — run before pushing
```

Coverage report is written to `coverage/index.html`.

## Rake Tasks

```bash
# Backfill FriendlyId slugs for articles missing one
bin/rails slugs:backfill_articles

# Generate OG social card images for published articles that don't have one yet
bin/rails og_images:generate

# Regenerate OG social cards for all published articles (e.g. after a design change)
bin/rails og_images:generate FORCE=true
```

## Architecture Notes

- Custom session-based auth (Rails 8 generator, no Devise). Only `admin?` users can write.
- Articles use `friendly_id` on `:title` — URLs are `/articles/my-title`.
- `Article.visible_to(user)` — admins see all, guests see published only.
- Tags use a custom `to_param` (hyphenated) and `Tag.find_by_param`.
- Stimulus controllers in `app/javascript/controllers/`.
- Dashboard namespace at `/admin` is gated by a routing constraint (signed session cookie + `admin?`).
