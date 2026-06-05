# Roadmap

## Migrate from Madmin to Custom Dashboard

Replace the `madmin` gem with a custom `Dashboard::` namespace that lives fully inside the existing Rails app — same Bootstrap layout, same Stimulus controllers, same auth concern. No parallel asset pipeline, no `main_app.` workarounds.

### What madmin currently provides

| Resource | Custom logic? | Notes |
|---|---|---|
| Articles CRUD | Yes — `create` assigns `Current.user` | Most complex form |
| Users CRUD | No | Simple fields |
| Tags CRUD | No | Simple fields |
| Sessions (read + destroy) | No | Read-only |
| ArticleTags | No | Rarely used directly |
| Active Storage / ActionText resources | No | Hidden from nav, not needed |
| Dashboard root | No | Landing page only |
| Auth constraint on routes | Yes | `ADMIN_CONSTRAINT` lambda already in place |

### What gets reused as-is

- `Authentication` concern — no changes
- `Articles::RemoveImageController` — keep it
- `Articles::ImageLibraryController` — keep it
- `image_picker_controller.js`, `tom_select_controller.js` — already work in Bootstrap context
- `articles/_form.html.erb` and its partials — dashboard article form renders this directly
- `ADMIN_CONSTRAINT` lambda — move into new routes file

---

### ~~Phase 1 — Dashboard skeleton~~

- ~~Create `Dashboard::BaseController < ApplicationController` with `before_action :admin_only!`~~
- ~~Create a `dashboard#index` landing page~~
- ~~Rewrite `config/routes/madmin.rb` → `config/routes/dashboard.rb` with the same constraint pointing at the `Dashboard::` namespace~~
- ~~Keep the `/admin` path so no URLs change~~

### ~~Phase 2 — Articles CRUD~~

- ~~`Dashboard::ArticlesController` — full CRUD~~
- ~~Render the existing `articles/_form.html.erb` partial directly (Bootstrap, works out of the box)~~
- ~~`create` always sets `user = Current.user` (guaranteed admin — no fallback needed)~~
- ~~Port the 8-line custom create action from `Madmin::ArticlesController`~~

### ~~Phase 3 — Users~~

- ~~`Dashboard::UsersController` — index, show, edit, update~~
- ~~Form fields: email address, admin toggle, password change~~
- ~~No create/destroy (admin account is seeded)~~

### ~~Phase 4 — Tags~~

- ~~`Dashboard::TagsController` — full CRUD~~
- ~~Standard HTML form (unlike the frontend tags controller which is JSON-only)~~

### ~~Phase 5 — Sessions~~

- ~~`Dashboard::SessionsController` — index + destroy~~
- ~~Shows IP address, user agent, created_at for each session~~
- ~~One-click revoke~~

### Phase 6 — Layout

- New `app/views/layouts/dashboard.html.erb` extending the existing Bootstrap setup (same `<head>`, same importmap)
- Bootstrap sidebar or top navbar with links to Articles, Users, Tags, Sessions
- Replaces the madmin Tailwind layout entirely

### Phase 7 — Remove madmin

Once all phases are complete and tests pass:

- Remove `gem "madmin"` from Gemfile
- Delete:
  - `app/controllers/madmin/`
  - `app/madmin/`
  - `app/views/madmin/`
  - `app/views/layouts/madmin/`
  - `app/javascript/madmin/`
  - `app/assets/stylesheets/madmin_custom.css`
- Remove madmin request specs, update route constraint location
- Run `bundle install` and full test suite

---

### Effort estimate

| Phase | Complexity | Notes |
|---|---|---|
| ~~1 — Skeleton + routes~~ | ~~Low~~ | ~~~30 min~~ |
| ~~2 — Articles~~ | ~~Medium~~ | ~~Form reuse makes this fast~~ |
| ~~3 — Users~~ | ~~Low~~ | ~~Simple form~~ |
| ~~4 — Tags~~ | ~~Low~~ | ~~Simplest CRUD~~ |
| ~~5 — Sessions~~ | ~~Low~~ | ~~Read-only~~ |
| 6 — Layout | Low–Medium | Bootstrap, no new concepts |
| 7 — Remove madmin | Low | Delete files + bundle |