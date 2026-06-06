# Guard clause: only run seeds in development environment
unless Rails.env.development?
  puts "Skipping seed data - only runs in development environment"
  raise "Skipping seed data - only runs in development environment"
end

require "open-uri"

# Create tags
puts "Creating tags..."
tags_data = ["ruby", "rails", "javascript", "css", "programming", "web development", "tutorial", "best practices"]
tags = tags_data.map { |name| Tag.find_or_create_by!(name: name) }
puts "Created #{tags.count} tags"

article_contents = [
  {
    title: "Getting Started with Ruby on Rails",
    content: <<~HTML
      <h2>What is Rails?</h2>
      <p>Ruby on Rails is a full-stack web application framework written in Ruby. It follows the MVC pattern and emphasizes convention over configuration, letting you build production-ready applications quickly.</p>
      <h2>Why Choose Rails?</h2>
      <ul>
        <li>Rapid development with sensible defaults</li>
        <li>Rich ecosystem of gems</li>
        <li>Built-in security features (CSRF, SQL injection protection)</li>
        <li>Active Record makes database work a pleasure</li>
      </ul>
      <h2>Your First Route</h2>
      <p>Open <code>config/routes.rb</code> and add a root route to get started:</p>
      <pre data-language="ruby">Rails.application.routes.draw do
  root "articles#index"
  resources :articles
end</pre>
      <p>Then generate a controller with <code>bin/rails generate controller Articles index</code> and you have a working page.</p>
    HTML
  },
  {
    title: "Understanding Active Record Associations",
    content: <<~HTML
      <h2>Defining Relationships</h2>
      <p>Active Record associations let you declare relationships between models in plain Ruby. Rails handles the SQL so you can focus on your domain logic.</p>
      <h2>The Most Common Associations</h2>
      <pre data-language="ruby">class User &lt; ApplicationRecord
  has_many :articles, dependent: :destroy
  has_one  :profile
end

class Article &lt; ApplicationRecord
  belongs_to :user
  has_many   :article_tags
  has_many   :tags, through: :article_tags
end</pre>
      <h2>Tips</h2>
      <ul>
        <li>Always add a database-level foreign key alongside <code>belongs_to</code></li>
        <li>Use <code>dependent: :destroy</code> to prevent orphaned records</li>
        <li>Prefer <code>has_many :through</code> over <code>has_and_belongs_to_many</code> when you need extra columns on the join</li>
      </ul>
    HTML
  },
  {
    title: "Mastering CSS Grid Layout",
    content: <<~HTML
      <h2>Why Grid?</h2>
      <p>CSS Grid is the first CSS layout system built for two-dimensional design. It makes complex, responsive layouts trivial to write and easy to read.</p>
      <h2>Basic Setup</h2>
      <pre data-language="css">.container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}</pre>
      <h2>Key Concepts</h2>
      <ul>
        <li><strong>fr unit</strong> — fractional share of available space</li>
        <li><strong>grid-template-areas</strong> — name regions for readable layouts</li>
        <li><strong>auto-fill / auto-fit</strong> — responsive columns without media queries</li>
      </ul>
      <p>Combine Grid for page layout with Flexbox for component alignment and you have a complete toolkit.</p>
    HTML
  },
  {
    title: "JavaScript Async/Await Patterns",
    content: <<~HTML
      <h2>From Callbacks to Async/Await</h2>
      <p>Async/await is syntactic sugar over Promises that makes asynchronous code read like synchronous code — easier to write, easier to debug.</p>
      <h2>Basic Pattern</h2>
      <pre data-language="javascript">async function fetchArticle(id) {
  try {
    const response = await fetch(`/api/articles/${id}`);
    if (!response.ok) throw new Error(response.statusText);
    return await response.json();
  } catch (error) {
    console.error("Fetch failed:", error);
  }
}</pre>
      <h2>Common Pitfalls</h2>
      <ul>
        <li>Forgetting <code>await</code> inside loops — use <code>Promise.all</code> for parallel fetches</li>
        <li>Catching errors too broadly — handle at the right level</li>
        <li>Using async/await where a plain Promise chain is cleaner</li>
      </ul>
    HTML
  },
  {
    title: "Testing with RSpec: A Comprehensive Guide",
    content: <<~HTML
      <h2>Why RSpec?</h2>
      <p>RSpec's readable DSL encourages you to describe behavior rather than just test methods. Tests become living documentation of what your code does.</p>
      <h2>A Well-Structured Spec</h2>
      <pre data-language="ruby">RSpec.describe Article, type: :model do
  subject(:article) { build(:article) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to belong_to(:user) }
  end

  describe "#publish!" do
    it "sets is_published and published_at" do
      expect { article.publish! }
        .to change(article, :is_published).to(true)
        .and change(article, :published_at).from(nil)
    end
  end
end</pre>
      <h2>Good Habits</h2>
      <ul>
        <li>One expectation per example keeps failures obvious</li>
        <li>Use FactoryBot — never fixtures</li>
        <li>Describe behavior, not implementation</li>
      </ul>
    HTML
  },
  {
    title: "Building RESTful APIs with Rails",
    content: <<~HTML
      <h2>Rails as an API</h2>
      <p>Rails ships with an API-only mode that strips out middleware you don't need, giving you a leaner stack for JSON services.</p>
      <h2>A Clean Controller</h2>
      <pre data-language="ruby">module Api
  module V1
    class ArticlesController &lt; ApplicationController
      def index
        articles = Article.published.order(published_at: :desc)
        render json: articles, status: :ok
      end

      def create
        article = Article.new(article_params)
        if article.save
          render json: article, status: :created
        else
          render json: { errors: article.errors }, status: :unprocessable_content
        end
      end
    end
  end
end</pre>
      <h2>Versioning</h2>
      <p>Namespace your controllers under <code>Api::V1</code> from day one. Introducing a <code>V2</code> without breaking existing clients is much easier when the structure is already there.</p>
    HTML
  },
  {
    title: "Rails Database Performance Tips",
    content: <<~HTML
      <h2>The N+1 Problem</h2>
      <p>The most common Rails performance issue: loading a collection and then hitting the database once per record to fetch an association.</p>
      <pre data-language="ruby"># Bad — 1 query for articles + N queries for users
articles = Article.all
articles.each { |a| puts a.user.email }

# Good — 2 queries total
articles = Article.includes(:user).all
articles.each { |a| puts a.user.email }</pre>
      <h2>Add Indexes That Matter</h2>
      <pre data-language="ruby">add_index :articles, :published_at
add_index :articles, [:user_id, :is_published]</pre>
      <h2>Quick Wins</h2>
      <ul>
        <li>Use <code>pluck</code> when you only need one column</li>
        <li>Scope queries with <code>select</code> to avoid loading unused columns</li>
        <li>Counter caches eliminate count queries on associations</li>
      </ul>
    HTML
  },
  {
    title: "Docker for Rails Development",
    content: <<~HTML
      <h2>Why Docker?</h2>
      <p>Docker gives every developer on your team the same environment — the same Ruby version, the same database, the same system libraries. No more "works on my machine".</p>
      <h2>A Minimal Dockerfile</h2>
      <pre data-language="dockerfile">FROM ruby:3.4-slim

WORKDIR /app

RUN apt-get update &amp;&amp; apt-get install -y build-essential libsqlite3-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]</pre>
      <h2>Development Compose</h2>
      <p>Use <code>docker-compose.yml</code> to wire up Rails with a database and any other services (Redis, Sidekiq) in a single <code>docker compose up</code>.</p>
    HTML
  },
  {
    title: "Hotwire: Reactive Rails Without JavaScript Frameworks",
    content: <<~HTML
      <h2>What is Hotwire?</h2>
      <p>Hotwire (Turbo + Stimulus) lets you build fast, reactive interfaces by sending HTML over the wire instead of JSON. You keep all your logic in Ruby, on the server.</p>
      <h2>Turbo Frames</h2>
      <pre data-language="erb">&lt;%= turbo_frame_tag "article_\#{article.id}" do %&gt;
  &lt;%= render article %&gt;
&lt;% end %&gt;</pre>
      <p>Wrap any section of the page in a Turbo Frame and links inside it will update only that frame — no page reload, no JavaScript required.</p>
      <h2>Turbo Streams</h2>
      <p>After a form submission, respond with a Turbo Stream to append, prepend, replace, or remove elements on the page — all from a Rails controller returning HTML.</p>
      <ul>
        <li>No Redux, no fetch, no state management</li>
        <li>Progressive enhancement — works without JavaScript too</li>
        <li>Pairs naturally with Action Cable for real-time updates</li>
      </ul>
    HTML
  },
  {
    title: "Git Workflow Best Practices",
    content: <<~HTML
      <h2>Keep Commits Small and Focused</h2>
      <p>A commit should do one thing. Small commits are easier to review, easier to revert, and make <code>git bisect</code> useful when tracking down bugs.</p>
      <h2>Feature Branch Workflow</h2>
      <pre data-language="bash"># Branch from main
git checkout -b feature/turbo-pagination

# Commit early, commit often
git add app/controllers/articles_controller.rb
git commit -m "feat: add Pagy pagination to articles index"

# Keep your branch current
git fetch origin
git rebase origin/main</pre>
      <h2>Write Good Commit Messages</h2>
      <ul>
        <li>Subject line: imperative mood, 50 chars or fewer</li>
        <li>Body: explain <em>why</em>, not what (the diff shows what)</li>
        <li>Reference issue numbers when relevant</li>
      </ul>
    HTML
  },
  {
    title: "Action Text and Rich Content in Rails",
    content: <<~HTML
      <h2>Adding Action Text</h2>
      <p>Action Text brings rich-text editing to Rails with Trix. Run the installer and you get file storage, embedded attachments, and a polished editor out of the box.</p>
      <pre data-language="bash">bin/rails action_text:install
bin/rails db:migrate</pre>
      <h2>In Your Model</h2>
      <pre data-language="ruby">class Article &lt; ApplicationRecord
  has_rich_text :content
end</pre>
      <h2>In Your Form</h2>
      <pre data-language="erb">&lt;%= form.rich_text_area :content %&gt;</pre>
      <h2>Rendering</h2>
      <p>Use <code>&lt;%= article.content %&gt;</code> in your view. Action Text handles sanitization automatically — only a safe allowlist of HTML tags is ever rendered.</p>
    HTML
  },
  {
    title: "Security Best Practices for Rails Apps",
    content: <<~HTML
      <h2>Rails Security Defaults</h2>
      <p>Rails ships with strong defaults: CSRF protection on all non-GET requests, SQL injection protection through parameterized queries, and XSS protection through automatic HTML escaping.</p>
      <h2>Parameterized Queries</h2>
      <pre data-language="ruby"># Never interpolate user input into SQL
User.where("email = '\#{params[:email]}'")  # dangerous

# Always use parameterized form
User.where(email: params[:email])           # safe</pre>
      <h2>Checklist</h2>
      <ul>
        <li>Run <code>brakeman</code> in CI to catch vulnerabilities automatically</li>
        <li>Run <code>bundler-audit</code> to flag gems with known CVEs</li>
        <li>Use Strong Parameters — never pass <code>params</code> directly to a model</li>
        <li>Set a Content Security Policy in <code>config/initializers/content_security_policy.rb</code></li>
      </ul>
    HTML
  },
  {
    title: "Building a CI/CD Pipeline with GitHub Actions",
    content: <<~HTML
      <h2>Why Automate?</h2>
      <p>A CI pipeline catches broken builds before they reach main. A CD pipeline removes the fear of deploying by making it a routine, automated event.</p>
      <h2>Basic Rails CI Workflow</h2>
      <pre data-language="yaml">name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bin/rails db:test:prepare
      - run: bin/rspec
      - run: bin/brakeman --no-pager</pre>
      <h2>Next Steps</h2>
      <ul>
        <li>Add a deploy job that runs on push to <code>main</code> only</li>
        <li>Use Kamal for zero-downtime deploys to a VPS</li>
        <li>Cache the bundle with <code>bundler-cache: true</code> to keep builds fast</li>
      </ul>
    HTML
  },
  {
    title: "Stimulus: Just Enough JavaScript",
    content: <<~HTML
      <h2>The Stimulus Philosophy</h2>
      <p>Stimulus doesn't take over your page. It connects small, focused JavaScript controllers to existing HTML elements — perfect alongside Turbo or any server-rendered app.</p>
      <h2>A Simple Controller</h2>
      <pre data-language="javascript">// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
  }
}</pre>
      <h2>Connecting to HTML</h2>
      <pre data-language="html">&lt;div data-controller="clipboard"&gt;
  &lt;input data-clipboard-target="source" value="Copy me"&gt;
  &lt;button data-action="click-&gt;clipboard#copy"&gt;Copy&lt;/button&gt;
&lt;/div&gt;</pre>
      <p>No build step needed with importmap — just write the file and use it.</p>
    HTML
  },
  {
    title: "Deploying Rails with Kamal",
    content: <<~HTML
      <h2>What is Kamal?</h2>
      <p>Kamal is Rails' official deployment tool. It uses Docker to package your app and deploys it to any VPS with zero downtime via container rolling restarts.</p>
      <h2>Minimal config/deploy.yml</h2>
      <pre data-language="yaml">service: my_blog
image: user/my_blog

servers:
  web:
    - 192.168.1.1

registry:
  username: user
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL</pre>
      <h2>Deploy in Three Steps</h2>
      <ol>
        <li>Push your image: <code>kamal build push</code></li>
        <li>First deploy: <code>kamal setup</code></li>
        <li>Every deploy after: <code>kamal deploy</code></li>
      </ol>
      <p>Kamal handles health checks, rollbacks, and secrets management — production-grade deploys without Heroku pricing.</p>
    HTML
  }
]

image_urls = (1..15).map { |i| "https://picsum.photos/seed/article#{i}/1200/800" }

puts "Creating articles..."

user = User.find_by!(admin: true)

article_contents.each_with_index do |data, index|
  existing = Article.find_by(title: data[:title])

  if existing
    puts "✓ Already exists: #{existing.title}"
    next
  end

  article = Article.new(
    title: data[:title],
    content: data[:content],
    is_published: true,
    published_at: Time.current - (15 - index).days,
    user: user
  )

  begin
    article.image.attach(
      io: URI.open(image_urls[index]),
      filename: "article_#{index + 1}.jpg",
      content_type: "image/jpeg"
    )
    article.tags = tags.sample(rand(1..3))

    if article.save
      puts "✓ Created: #{article.title}"
    else
      puts "✗ Failed: #{article.title} — #{article.errors.full_messages.join(', ')}"
    end
  rescue => e
    puts "✗ Error on #{data[:title]}: #{e.message}"
  end
end

puts "\nDone. #{Article.count} articles total."
