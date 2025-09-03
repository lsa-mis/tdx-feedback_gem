# Database Schema

Complete documentation of the database structure, validations, and migrations for the TDX Feedback Gem.

## 📊 Overview

The gem creates a single table `tdx_feedback_gem_feedbacks` to store feedback submissions. This table is designed to be lightweight while capturing all necessary information for feedback processing and TDX ticket creation.

## 🗄️ Table Structure

### `tdx_feedback_gem_feedbacks` Table

```sql
CREATE TABLE tdx_feedback_gem_feedbacks (
  id bigint NOT NULL,
  message text NOT NULL,
  context text,
  user_id bigint,
  tdx_ticket_id varchar(255),
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);
```

### Field Definitions

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | `bigint` | `PRIMARY KEY`, `NOT NULL`, `AUTO_INCREMENT` | Unique identifier for the feedback |
| `message` | `text` | `NOT NULL` | The main feedback message from the user |
| `context` | `text` | `NULL` | Additional context information (optional) |
| `user_id` | `bigint` | `NULL`, `FOREIGN KEY` | Associated user ID (if authentication enabled) |
| `tdx_ticket_id` | `varchar(255)` | `NULL` | TDX ticket ID after successful creation |
| `created_at` | `timestamp` | `NOT NULL` | When the feedback was submitted |
| `updated_at` | `timestamp` | `NOT NULL` | When the feedback was last updated |

## 🔗 Model Relationships

### Feedback Model

```ruby
# app/models/tdx_feedback_gem/feedback.rb
module TdxFeedbackGem
  class Feedback < ApplicationRecord
    # Table name configuration
    self.table_name = 'tdx_feedback_gem_feedbacks'

    # Associations
    belongs_to :user, optional: true

    # Validations
    validates :message, presence: true, length: { maximum: 10000 }
    validates :context, length: { maximum: 10000 }, allow_blank: true
    validates :tdx_ticket_id, length: { maximum: 255 }, allow_blank: true

    # Scopes
    scope :recent, -> { order(created_at: :desc) }
    scope :with_tdx_tickets, -> { where.not(tdx_ticket_id: nil) }
    scope :without_tdx_tickets, -> { where(tdx_ticket_id: nil) }

    # Instance methods
    def has_tdx_ticket?
      tdx_ticket_id.present?
    end

    def tdx_ticket_created?
      has_tdx_ticket?
    end
  end
end
```

### User Association (Optional)

```ruby
# In your User model
class User < ApplicationRecord
  # Optional: Add feedback association
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback'

  # Helper methods
  def feedback_count
    feedbacks.count
  end

  def recent_feedback(limit = 5)
    feedbacks.recent.limit(limit)
  end
end
```

## 📝 Migration Files

### Initial Migration

```ruby
# db/migrate/[timestamp]_create_tdx_feedback_gem_feedbacks.rb
class CreateTdxFeedbackGemFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :tdx_feedback_gem_feedbacks do |t|
      t.text :message, null: false
      t.text :context
      t.references :user, null: true, foreign_key: true
      t.string :tdx_ticket_id

      t.timestamps
    end

    # Indexes for performance
    add_index :tdx_feedback_gem_feedbacks, :user_id
    add_index :tdx_feedback_gem_feedbacks, :tdx_ticket_id
    add_index :tdx_feedback_gem_feedbacks, :created_at
  end
end
```

### Adding Custom Fields (Optional)

```ruby
# db/migrate/[timestamp]_add_custom_fields_to_tdx_feedback_gem_feedbacks.rb
class AddCustomFieldsToTdxFeedbackGemFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :tdx_feedback_gem_feedbacks, :feedback_type, :string
    add_column :tdx_feedback_gem_feedbacks, :priority, :integer, default: 2
    add_column :tdx_feedback_gem_feedbacks, :page_url, :string
    add_column :tdx_feedback_gem_feedbacks, :user_agent, :string

    # Indexes for new fields
    add_index :tdx_feedback_gem_feedbacks, :feedback_type
    add_index :tdx_feedback_gem_feedbacks, :priority
  end
end
```

## ✅ Validations

### Required Validations

```ruby
# Message validation
validates :message, presence: true, length: { maximum: 10000 }

# Ensures feedback has content
# Limits message length to prevent abuse
```

### Optional Validations

```ruby
# Context validation
validates :context, length: { maximum: 10000 }, allow_blank: true

# TDX ticket ID validation
validates :tdx_ticket_id, length: { maximum: 255 }, allow_blank: true

# User association validation
validates :user, presence: true, if: :require_authentication?
```

### Custom Validations

```ruby
# Custom validation example
validate :message_not_empty_after_stripping

private

def message_not_empty_after_stripping
  if message.present? && message.strip.blank?
    errors.add(:message, "cannot be only whitespace")
  end
end

def require_authentication?
  TdxFeedbackGem.configuration.require_authentication
end
```

## 🔍 Database Queries

### Common Queries

```ruby
# Get all feedback
TdxFeedbackGem::Feedback.all

# Get recent feedback
TdxFeedbackGem::Feedback.recent.limit(10)

# Get feedback with TDX tickets
TdxFeedbackGem::Feedback.with_tdx_tickets

# Get feedback without TDX tickets
TdxFeedbackGem::Feedback.without_tdx_tickets

# Get feedback by user
user.feedbacks.recent

# Get feedback count by date
TdxFeedbackGem::Feedback.group("DATE(created_at)").count

# Get feedback with context
TdxFeedbackGem::Feedback.where.not(context: [nil, ''])
```

### Performance Queries

```ruby
# Optimized query with includes
TdxFeedbackGem::Feedback.includes(:user).recent.limit(20)

# Pagination
TdxFeedbackGem::Feedback.page(params[:page]).per(25)

# Search functionality
TdxFeedbackGem::Feedback.where("message ILIKE ?", "%#{search_term}%")

# Date range queries
TdxFeedbackGem::Feedback.where(created_at: 1.week.ago..Time.current)
```

## 📊 Database Indexes

### Recommended Indexes

```sql
-- Primary key (automatically created)
CREATE INDEX idx_tdx_feedback_gem_feedbacks_id ON tdx_feedback_gem_feedbacks(id);

-- User association index
CREATE INDEX idx_tdx_feedback_gem_feedbacks_user_id ON tdx_feedback_gem_feedbacks(user_id);

-- TDX ticket ID index
CREATE INDEX idx_tdx_feedback_gem_feedbacks_tdx_ticket_id ON tdx_feedback_gem_feedbacks(tdx_ticket_id);

-- Created at index (for sorting and date queries)
CREATE INDEX idx_tdx_feedback_gem_feedbacks_created_at ON tdx_feedback_gem_feedbacks(created_at);

-- Composite index for user + date queries
CREATE INDEX idx_tdx_feedback_gem_feedbacks_user_created ON tdx_feedback_gem_feedbacks(user_id, created_at);
```

### Index Maintenance

```ruby
# Add indexes in migration
class AddIndexesToTdxFeedbackGemFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_index :tdx_feedback_gem_feedbacks, :user_id
    add_index :tdx_feedback_gem_feedbacks, :tdx_ticket_id
    add_index :tdx_feedback_gem_feedbacks, :created_at
    add_index :tdx_feedback_gem_feedbacks, [:user_id, :created_at]
  end
end
```

## 🗃️ Data Management

### Backup and Export

```ruby
# Export feedback data
class FeedbackExporter
  def self.export_to_csv(start_date = nil, end_date = nil)
    feedbacks = TdxFeedbackGem::Feedback.all

    if start_date && end_date
      feedbacks = feedbacks.where(created_at: start_date..end_date)
    end

    CSV.generate do |csv|
      csv << ['ID', 'Message', 'Context', 'User ID', 'TDX Ticket ID', 'Created At']

      feedbacks.each do |feedback|
        csv << [
          feedback.id,
          feedback.message,
          feedback.context,
          feedback.user_id,
          feedback.tdx_ticket_id,
          feedback.created_at
        ]
      end
    end
  end
end
```

### Data Cleanup

```ruby
# Clean up old feedback (optional)
class FeedbackCleanup
  def self.cleanup_old_feedback(days_to_keep = 365)
    cutoff_date = days_to_keep.days.ago

    # Delete old feedback without TDX tickets
    old_feedback = TdxFeedbackGem::Feedback
      .where('created_at < ? AND tdx_ticket_id IS NULL', cutoff_date)

    count = old_feedback.count
    old_feedback.destroy_all

    count
  end
end
```

## 🔧 Database Configuration

### PostgreSQL Configuration

```ruby
# config/database.yml
production:
  adapter: postgresql
  encoding: unicode
  database: your_app_production
  username: your_username
  password: your_password
  host: your_host
  port: 5432

  # Performance settings
  pool: 25
  timeout: 5000

  # Connection settings
  variables:
    statement_timeout: 5000
    lock_timeout: 1000
```

### MySQL Configuration

```ruby
# config/database.yml
production:
  adapter: mysql2
  encoding: utf8mb4
  database: your_app_production
  username: your_username
  password: your_password
  host: your_host
  port: 3306

  # Performance settings
  pool: 25
  timeout: 5000

  # MySQL specific settings
  variables:
    sql_mode: "STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO"
```

## 📈 Performance Considerations

### Query Optimization

```ruby
# Use counter cache for user feedback counts
class AddFeedbackCountToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :feedbacks_count, :integer, default: 0, null: false

    # Update existing counts
    User.find_each do |user|
      User.reset_counters(user.id, :feedbacks)
    end
  end
end

# In User model
class User < ApplicationRecord
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback'

  # Counter cache
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback', counter_cache: true
end
```

### Database Maintenance

```ruby
# Regular maintenance tasks
namespace :feedback do
  desc "Clean up old feedback data"
  task cleanup: :environment do
    puts "Cleaning up old feedback..."
    count = FeedbackCleanup.cleanup_old_feedback(365)
    puts "Cleaned up #{count} old feedback records"
  end

  desc "Reindex feedback table"
  task reindex: :environment do
    puts "Reindexing feedback table..."
    ActiveRecord::Base.connection.execute("REINDEX TABLE tdx_feedback_gem_feedbacks")
    puts "Reindexing complete"
  end
end
```

## 🚨 Common Database Issues

### Issue: Table Not Created

**Symptoms**:
- Migration not run
- Table doesn't exist

**Solutions**:
```bash
# Run migrations
rails db:migrate

# Check migration status
rails db:migrate:status

# Reset database (development only)
rails db:reset
```

### Issue: Foreign Key Constraints

**Symptoms**:
- User deletion fails
- Referential integrity errors

**Solutions**:
```ruby
# Add dependent destroy
class User < ApplicationRecord
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback', dependent: :destroy
end

# Or add nullify
class User < ApplicationRecord
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback', dependent: :nullify
end
```

### Issue: Performance Problems

**Symptoms**:
- Slow queries
- High database load

**Solutions**:
```ruby
# Add proper indexes
# Use counter caches
# Implement pagination
# Use database views for complex queries
```

## 🔄 Next Steps

Now that you understand the database schema:

1. **[API Endpoints](API-Endpoints)** - REST API documentation and examples
2. **[Performance Optimization](Performance-Optimization)** - Database and query optimization
3. **[Production Deployment](Production-Deployment)** - Database configuration and maintenance
4. **[Testing Guide](Testing)** - Test your database setup

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more details about the API endpoints, see the [API Endpoints](API-Endpoints) guide.*
