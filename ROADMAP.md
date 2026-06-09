# Roadmap

## Projects Portfolio Feature

Replace the ad-hoc `RubygemsService` display with a proper `Project` resource that supports any type of software project (RubyGems, GitHub repos, npm packages, etc.), admin-managed CRUD, and an optional daily sync for gem metadata.

### Phase 5 — Public Projects Page

Add a read-only `ProjectsController#index` (`GET /projects`) visible to all visitors:

- Loads `Project.where(is_featured: true).order(:position)` first, then the rest
- Groups or tabs by `project_type` if useful
- No `ProjectsController#show` needed initially — `url` links out directly

---

### Out of Scope (for now)

- Download/install stats from RubyGems
- GitHub star/fork counts
- npm package support (model supports it, but no sync job)
- Project images / logos