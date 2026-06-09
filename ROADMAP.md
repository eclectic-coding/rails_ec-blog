# Roadmap

## Projects Portfolio Feature

Replace the ad-hoc `RubygemsService` display with a proper `Project` resource that supports any type of software project (RubyGems, GitHub repos, npm packages, etc.), admin-managed CRUD, and an optional daily sync for gem metadata.

### Phase 4 — Daily Sync Job

Create `ProjectSyncJob < ApplicationJob` that updates gem metadata for all projects where `rubygem_name` is present:

1. Fetch individual gem data from `https://rubygems.org/api/v1/gems/{name}.json`
2. Update `version`, `description`, `last_synced_at` only — never overwrite `name`, `url`, `is_featured`, or `position` (those are editorial)
3. Silence errors per-gem (log and continue) so one bad gem doesn't abort the batch

Schedule via a **Solid Queue recurring job** (Rails 8 built-in) in `config/recurring.yml`:

```yaml
sync_projects:
  class: ProjectSyncJob
  schedule: every day at 3am
```

No download stats — only version and description are synced.

---

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