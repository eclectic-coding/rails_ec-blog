# Roadmap

## Projects Portfolio Feature

Replace the ad-hoc `RubygemsService` display with a proper `Project` resource that supports any type of software project (RubyGems, GitHub repos, npm packages, etc.), admin-managed CRUD, and an optional daily sync for gem metadata.

### Out of Scope (for now)

- Download/install stats from RubyGems
- GitHub star/fork counts
- npm package support (model supports it, but no sync job)
- Project images / logos