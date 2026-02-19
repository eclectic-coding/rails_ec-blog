# Tag Feature - Usage Guide

## Accessing Tags

### 1. Browse All Tags
- Navigate to: **http://localhost:3000/tags**
- View all tags as clickable badges with article counts
- Click any tag to see articles with that tag

### 2. Filter by Tag
- Navigate to: **http://localhost:3000/tags/:id**
- See all published articles with the selected tag
- Pagination supported for large tag lists

### 3. View Tags on Articles
- **Article Index** (`/articles`) - Each article card shows its tags as badges
- **Article Show** (`/articles/:id`) - Tags displayed at the top as clickable badges
- Click any tag badge to filter articles by that tag

## Creating/Editing Articles with Tags

### When Creating a New Article:
1. Navigate to `/articles/new` (admin only)
2. Fill in article details
3. **Select at least one tag** (required) using checkboxes
4. Click "Create Article"

### When Editing an Article:
1. Navigate to `/articles/:id/edit` (admin only)
2. Update article details
3. **Check/uncheck tags** to update tag associations
4. Must have at least one tag selected
5. Click "Update Article"

## Tag Validation

**Required:** Every article MUST have at least one tag.

If you try to save an article without tags:
- ❌ Validation error: "Tags must have at least one tag"
- Form will redisplay with error message
- No article will be created/updated

## Tag Features

✅ **Case-insensitive** - "Ruby", "ruby", "RUBY" are all the same tag
✅ **Auto-normalized** - Extra spaces trimmed, converted to lowercase
✅ **Unique** - No duplicate tags allowed
✅ **Clickable** - All tag badges link to filtered article views
✅ **Counted** - Tag index shows article count for each tag

## Database Relationships

```
Article ←→ ArticleTag ←→ Tag
(many)      (join)      (many)
```

- Articles can have many tags
- Tags can be on many articles
- Deleting an article removes its tag associations
- Deleting a tag removes associations but not articles

## API Endpoints

### Public (No Auth Required)
- `GET /tags` - List all tags
- `GET /tags/:id` - Show articles for tag

### Admin Only
- Tags are managed through article create/edit forms
- No direct tag CRUD endpoints (future enhancement)

## Seeds

Run `bin/rails db:seed` to:
- Create 8 default tags
- Assign 1-3 random tags to existing articles

Default tags:
- ruby
- rails
- javascript
- css
- programming
- web development
- tutorial
- best practices

## Testing

Run tag-related tests:
```bash
# All tag tests
bin/rspec spec/models/tag_spec.rb spec/models/article_tag_spec.rb spec/controllers/tags_controller_spec.rb

# Just model tests
bin/rspec spec/models/tag_spec.rb

# Just request tests
bin/rspec spec/controllers/tags_controller_spec.rb
```

