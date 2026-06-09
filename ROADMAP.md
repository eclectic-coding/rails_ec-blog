# Roadmap

## Projects Portfolio Feature

Replace the ad-hoc `RubygemsService` display with a proper `Project` resource that supports any type of software project (RubyGems, GitHub repos, npm packages, etc.), admin-managed CRUD, and an optional daily sync for gem metadata.

### Motivation

The current `RubygemsService` only covers RubyGems and has no persistence — it fetches live on every page load (with caching). A persisted `Project` model gives full editorial control, supports non-gem projects, and decouples the public display from the upstream API.

---

### Phase 1 — Project Model & Migration

Create the `projects` table with fields that cover both manually-entered and API-synced projects:

| Column | Type | Notes |
|---|---|---|
| `name` | string | display name |
| `description` | text | short blurb |
| `url` | string | live project / docs URL |
| `source_url` | string | GitHub or repo link |
| `project_type` | string | `rubygem`, `github`, `npm`, `other` |
| `rubygem_name` | string | gem slug used for sync (nullable) |
| `version` | string | current release (synced or manual) |
| `is_featured` | boolean | pin to top of public list |
| `position` | integer | manual sort order |
| `last_synced_at` | datetime | set by sync job |
| `timestamps` | | standard |

Validations: `name` and `url` required; `project_type` in allowlist.

---

### Phase 2 — Admin CRUD

Add a `Admin::ProjectsController` (or route under the existing `dashboard/` namespace, matching current convention) with standard `index / new / create / edit / update / destroy` actions, gated behind `admin_only!`.

- Index table shows name, type, version, last_synced_at, featured toggle
- Form: all fields; `rubygem_name` shown only when type is `rubygem`
- Stimulus controller to conditionally show/hide `rubygem_name` field based on `project_type` select
- Flash notices on create/update/destroy

---

### Phase 3 — RubyGems Import Helper

Add a one-click "Import from RubyGems" action (`POST /admin/projects/import_rubygems`) that:

1. Calls `RubygemsService.gems` (existing fetch-all endpoint)
2. For each gem not already in `projects` (matched by `rubygem_name`), upserts a `Project` row with `project_type: "rubygem"` and populated `name`, `description`, `url`, `version`
3. Redirects to index with a summary flash ("3 gems imported, 2 already existed")

This makes initial population fast without manual entry.

---

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