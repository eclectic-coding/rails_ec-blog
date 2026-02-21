# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Guard clause: only run seeds in development environment
unless Rails.env.development?
  puts "Skipping seed data - only runs in development environment"
  raise "Skipping seed data - only runs in development environment"
end

require 'open-uri'

# Create tags
puts "Creating tags..."
tags_data = ['ruby', 'rails', 'javascript', 'css', 'programming', 'web development', 'tutorial', 'best practices']
tags = tags_data.map do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
end
puts "Created #{tags.count} tags"

# Sample markdown contents with different typography and code blocks
article_contents = [
  {
    title: "Getting Started with Ruby on Rails",
    content: <<~MARKDOWN
      # Introduction to Rails

      Ruby on Rails is a **powerful** web application framework written in *Ruby*. It follows the **MVC** pattern and emphasizes convention over configuration.

      ## Why Choose Rails?

      - Rapid development
      - Strong community support
      - Built-in security features

      ### Sample Code

      ```ruby
      class ApplicationController < ActionController::Base
        before_action :authenticate_user!

        def index
          @users = User.all
        end
      end
      ```

      Rails makes it easy to build modern web applications with minimal configuration.
    MARKDOWN
  },
  {
    title: "Understanding Active Record Associations",
    content: <<~MARKDOWN
      # Active Record Associations

      Active Record makes it **simple** to define relationships between models. Let's explore the different types of associations.

      ## Types of Associations

      1. `belongs_to`
      2. `has_many`
      3. `has_one`
      4. `has_and_belongs_to_many`

      ### Example Implementation

      ```ruby
      class User < ApplicationRecord
        has_many :articles, dependent: :destroy
        has_one :profile
        validates :email, presence: true
      end
      ```

      > Remember: Always add proper validations and foreign keys!

      The `dependent: :destroy` option ensures that associated records are cleaned up properly.
    MARKDOWN
  },
  {
    title: "Mastering CSS Grid Layout",
    content: <<~MARKDOWN
      # CSS Grid Layout Guide

      CSS Grid is a **two-dimensional** layout system for the web. It makes creating complex responsive layouts *much easier*.

      ## Basic Grid Setup

      ```css
      .container {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
        padding: 20px;
      }
      ```

      ### Key Properties

      - `grid-template-columns` - defines column tracks
      - `grid-template-rows` - defines row tracks
      - `gap` - sets spacing between items

      **Important:** Browser support is excellent across all modern browsers!
    MARKDOWN
  },
  {
    title: "JavaScript Async/Await Patterns",
    content: <<~MARKDOWN
      # Modern Async JavaScript

      The **async/await** syntax makes working with *Promises* much more readable and maintainable.

      ## Basic Example

      ```javascript
      async function fetchUserData(userId) {
        try {
          const response = await fetch(`/api/users/${userId}`);
          const data = await response.json();
          return data;
        } catch (error) {
          console.error('Error fetching user:', error);
        }
      }
      ```

      ### Benefits

      1. **Cleaner code** - no callback hell
      2. **Better error handling** - try/catch blocks
      3. **Easier debugging** - standard call stack

      > Pro tip: Always handle errors properly in production code!
    MARKDOWN
  },
  {
    title: "Testing with RSpec: A Comprehensive Guide",
    content: <<~MARKDOWN
      # RSpec Testing Best Practices

      RSpec is the **most popular** testing framework for Ruby applications. Let's explore how to write *effective* tests.

      ## Structure of a Test

      ```ruby
      RSpec.describe Article, type: :model do
        describe 'validations' do
          it 'validates presence of title' do
            article = Article.new(title: nil)
            expect(article).not_to be_valid
          end
        end
      end
      ```

      ### Key Concepts

      - **describe** - groups related tests
      - **it** - defines a single test case
      - **expect** - makes assertions

      Always follow the *Arrange-Act-Assert* pattern for clarity!
    MARKDOWN
  },
  {
    title: "Building RESTful APIs with Rails",
    content: <<~MARKDOWN
      # RESTful API Development

      Creating **RESTful APIs** in Rails is straightforward thanks to its *opinionated* structure.

      ## Sample Controller

      ```ruby
      class Api::V1::ArticlesController < ApplicationController
        def index
          articles = Article.published.recent
          render json: articles, status: :ok
        end

        def create
          article = Article.new(article_params)
          if article.save
            render json: article, status: :created
          else
            render json: { errors: article.errors }, status: :unprocessable_entity
          end
        end
      end
      ```

      ### HTTP Status Codes

      | Code | Meaning |
      |------|---------|
      | 200 | OK |
      | 201 | Created |
      | 422 | Unprocessable Entity |

      Always use the **appropriate status codes** for better API design!
    MARKDOWN
  },
  {
    title: "PostgreSQL Performance Optimization",
    content: <<~MARKDOWN
      # Optimizing PostgreSQL Queries

      **PostgreSQL** is a powerful database, but you need to optimize queries for *best performance*.

      ## Adding Indexes

      ```sql
      CREATE INDEX idx_articles_published_at
      ON articles(published_at)
      WHERE is_published = true;

      CREATE INDEX idx_users_email
      ON users(email_address);
      ```

      ### Tips for Better Performance

      1. Use indexes on frequently queried columns
      2. Avoid N+1 queries
      3. Use `EXPLAIN ANALYZE` to understand query plans

      > Remember: Too many indexes can slow down writes!
    MARKDOWN
  },
  {
    title: "Docker for Rails Development",
    content: <<~MARKDOWN
      # Containerizing Rails Apps

      **Docker** makes it easy to create *consistent* development environments across teams.

      ## Sample Dockerfile

      ```dockerfile
      FROM ruby:3.3.0

      WORKDIR /app

      COPY Gemfile Gemfile.lock ./
      RUN bundle install

      COPY . .

      EXPOSE 3000
      CMD ["rails", "server", "-b", "0.0.0.0"]
      ```

      ### Benefits of Docker

      - **Consistency** - same environment everywhere
      - **Isolation** - no conflicts with system packages
      - **Portability** - easy to share and deploy

      Use `docker-compose` for managing multiple services!
    MARKDOWN
  },
  {
    title: "Tailwind CSS: Utility-First Styling",
    content: <<~MARKDOWN
      # Getting Started with Tailwind

      Tailwind CSS is a **utility-first** CSS framework that makes styling *incredibly fast*.

      ## Example Usage

      ```html
      <div class="max-w-4xl mx-auto p-6">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">
          Welcome to Tailwind
        </h1>
        <p class="text-gray-600 leading-relaxed">
          Build beautiful designs without leaving your HTML.
        </p>
      </div>
      ```

      ### Common Utilities

      - `flex` / `grid` - layout systems
      - `text-{size}` - typography
      - `bg-{color}` - background colors
      - `p-{size}` - padding

      **Pro tip:** Use `@apply` for reusable component styles!
    MARKDOWN
  },
  {
    title: "Git Workflow Best Practices",
    content: <<~MARKDOWN
      # Effective Git Workflows

      A **solid Git workflow** is essential for *team collaboration* and code quality.

      ## Feature Branch Workflow

      ```bash
      # Create a new feature branch
      git checkout -b feature/user-authentication

      # Make changes and commit
      git add .
      git commit -m "Add user authentication"

      # Push to remote
      git push origin feature/user-authentication
      ```

      ### Commit Message Guidelines

      1. Use present tense ("Add feature" not "Added feature")
      2. Keep subject line under 50 characters
      3. Add detailed description if needed

      > Always review your changes before committing!
    MARKDOWN
  },
  {
    title: "React Hooks: useState and useEffect",
    content: <<~MARKDOWN
      # Understanding React Hooks

      React Hooks allow you to use **state** and other React features in *functional components*.

      ## Basic Hooks Example

      ```javascript
      import React, { useState, useEffect } from 'react';

      function UserProfile({ userId }) {
        const [user, setUser] = useState(null);
        const [loading, setLoading] = useState(true);

        useEffect(() => {
          fetch(`/api/users/${userId}`)
            .then(res => res.json())
            .then(data => {
              setUser(data);
              setLoading(false);
            });
        }, [userId]);

        if (loading) return <div>Loading...</div>;
        return <div>{user.name}</div>;
      }
      ```

      ### Hook Rules

      - Only call hooks at the **top level**
      - Only call hooks from React functions

      Hooks make your components *cleaner* and more reusable!
    MARKDOWN
  },
  {
    title: "Security Best Practices for Web Apps",
    content: <<~MARKDOWN
      # Web Application Security

      **Security** should never be an afterthought. Protect your users by following these *essential* practices.

      ## Common Vulnerabilities

      ### SQL Injection Prevention

      ```ruby
      # BAD - vulnerable to SQL injection
      User.where("email = '\#{params[:email]}'")

      # GOOD - uses parameterized queries
      User.where(email: params[:email])
      ```

      ### Key Security Measures

      1. **Validate all inputs** - never trust user data
      2. **Use HTTPS** - encrypt data in transit
      3. **Implement CSRF protection** - prevent cross-site attacks
      4. **Hash passwords** - never store plain text

      > Regular security audits are crucial for production apps!
    MARKDOWN
  },
  {
    title: "Building a CI/CD Pipeline",
    content: <<~MARKDOWN
      # Continuous Integration & Deployment

      **CI/CD** automates your testing and deployment process, ensuring *reliable* releases.

      ## GitHub Actions Example

      ```yaml
      name: CI

      on: [push, pull_request]

      jobs:
        test:
          runs-on: ubuntu-latest
          steps:
            - uses: actions/checkout@v2
            - name: Setup Ruby
              uses: ruby/setup-ruby@v1
              with:
                ruby-version: 3.3.0
            - name: Install dependencies
              run: bundle install
            - name: Run tests
              run: bundle exec rspec
      ```

      ### Benefits

      - **Automated testing** - catch bugs early
      - **Faster deployments** - ship with confidence
      - **Consistent process** - reduce human error

      Start simple and iterate on your pipeline!
    MARKDOWN
  },
  {
    title: "TypeScript for JavaScript Developers",
    content: <<~MARKDOWN
      # Introduction to TypeScript

      TypeScript adds **static typing** to JavaScript, making your code *more maintainable* and less error-prone.

      ## Type Definitions

      ```typescript
      interface User {
        id: number;
        name: string;
        email: string;
        isActive: boolean;
      }

      function greetUser(user: User): string {
        return `Hello, ${user.name}!`;
      }

      const user: User = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        isActive: true
      };
      ```

      ### Advantages

      - **Catch errors at compile time** - before runtime
      - **Better IDE support** - autocomplete and refactoring
      - **Self-documenting code** - types serve as documentation

      The learning curve is **worth it** for larger projects!
    MARKDOWN
  },
  {
    title: "Microservices Architecture Patterns",
    content: <<~MARKDOWN
      # Understanding Microservices

      **Microservices** break down monolithic applications into *smaller, independent* services.

      ## Service Communication

      ```python
      from flask import Flask, jsonify
      import requests

      app = Flask(__name__)

      @app.route('/api/user-profile/<int:user_id>')
      def get_user_profile(user_id):
          # Call other microservices
          user = requests.get(f'http://user-service/users/{user_id}')
          orders = requests.get(f'http://order-service/orders?user={user_id}')

          return jsonify({
              'user': user.json(),
              'orders': orders.json()
          })
      ```

      ### Key Considerations

      1. **Service boundaries** - define clear responsibilities
      2. **Data management** - each service owns its data
      3. **Communication** - REST, gRPC, or message queues

      > Start with a monolith and break it down gradually!

      Microservices add **complexity**, so only use them when needed.
    MARKDOWN
  }
]

# Image URLs for placeholder images (using picsum.photos for random images)
image_urls = (1..15).map { |i| "https://picsum.photos/seed/article#{i}/1200/800" }

puts "Creating articles with markdown content and images..."

user = User.find(1)

article_contents.each_with_index do |article_data, index|
  # Check if article already exists
  existing_article = Article.find_by(title: article_data[:title])

  if existing_article
    # Assign tags to existing articles if they don't have any
    if existing_article.tags.empty?
      num_tags = rand(1..3)
      existing_article.tags = tags.sample(num_tags)
      existing_article.save
      puts "✓ Article already exists, added tags: #{existing_article.title}"
    else
      puts "✓ Article already exists: #{existing_article.title}"
    end
    next
  end

  # Create new article
  article = Article.new(
    title: article_data[:title],
    content: article_data[:content],
    is_published: true,
    published_at: Time.current - rand(1..30).days,
    user: user
  )

  # Attach image before saving
  begin
    image_file = URI.open(image_urls[index])
    article.image.attach(
      io: image_file,
      filename: "article_#{index + 1}.jpg",
      content_type: 'image/jpeg'
    )

    # Assign random tags (1-3 tags per article)
    num_tags = rand(1..3)
    article.tags = tags.sample(num_tags)

    if article.save
      puts "✓ Created article: #{article.title} with image and #{article.tags.count} tags"
    else
      puts "✗ Error saving #{article.title}: #{article.errors.full_messages.join(', ')}"
    end
  rescue => e
    puts "✗ Error creating #{article.title}: #{e.message}"
  end
end

puts "\nSeed data creation complete!"
puts "Created #{Article.count} articles total."
