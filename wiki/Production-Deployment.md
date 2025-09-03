# Production Deployment

Complete guide to deploying the TDX Feedback Gem in production environments, including security, monitoring, scaling, and maintenance.

## 🚀 Deployment Overview

This guide covers everything you need to deploy the TDX Feedback Gem in production, from initial setup to ongoing maintenance and scaling.

## 🔧 Environment Configuration

### Production Environment Setup

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Force all access to the app over SSL
  config.force_ssl = true

  # Precompile additional assets
  config.assets.precompile += %w( tdx_feedback_gem.css tdx_feedback_gem.js )

  # Compress CSS using a preprocessor
  config.assets.css_compressor = :sass

  # Compress JavaScript
  config.assets.js_compressor = :terser

  # Enable fragment and page caching
  config.action_controller.perform_caching = true

  # Use a real cache store in production
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    connect_timeout: 30,
    read_timeout: 0.2,
    write_timeout: 0.2
  }

  # Log level
  config.log_level = :warn

  # Log tags
  config.log_tags = [:request_id, :remote_ip]

  # Use a different logger for distributed setups
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end
```

### TDX Feedback Gem Configuration

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  # === Production Settings ===
  config.environment = 'production'
  config.log_level = :warn

  # === TDX API Integration ===
  config.enable_ticket_creation = true
  config.tdx_base_url = ENV['TDX_BASE_URL']
  config.app_id = ENV['TDX_APP_ID']
  config.client_id = ENV['TDX_CLIENT_ID']
  config.client_secret = ENV['TDX_CLIENT_SECRET']
  config.service_id = ENV['TDX_SERVICE_ID']
  config.responsible_group_id = ENV['TDX_RESPONSIBLE_GROUP_ID']

  # === Performance Settings ===
  config.enable_caching = true
  config.cache_duration = 1.hour
  config.http_timeout = 30
  config.http_keep_alive = true
  config.enable_retry = true
  config.max_retries = 3

  # === Security Settings ===
  config.require_authentication = true
  config.enable_rate_limiting = true
  config.rate_limit = 10
  config.rate_limit_window = 1.minute

  # === Monitoring Settings ===
  config.enable_metrics = true
  config.enable_error_tracking = true
  config.enable_performance_monitoring = true
end
```

### Environment Variables

```bash
# .env.production
# TDX Configuration
TDX_BASE_URL=https://your-tdx-instance.teamdynamix.com
TDX_APP_ID=31
TDX_CLIENT_ID=your_client_id
TDX_CLIENT_SECRET=your_client_secret
TDX_SERVICE_ID=67
TDX_RESPONSIBLE_GROUP_ID=631

# Database
DATABASE_URL=postgresql://username:password@host:port/database
REDIS_URL=redis://username:password@host:port/database

# Security
SECRET_KEY_BASE=your_secret_key_base
RAILS_MASTER_KEY=your_master_key

# Monitoring
SENTRY_DSN=your_sentry_dsn
NEW_RELIC_LICENSE_KEY=your_new_relic_key

# Performance
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

## 🔒 Security Best Practices

### CSRF Protection

```ruby
# config/application.rb
class Application < Rails::Application
  # CSRF protection
  config.action_controller.forgery_protection_origin_check = true

  # Content Security Policy
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data
    policy.object_src :none
    policy.script_src :self, :https
    policy.style_src :self, :https, :unsafe_inline
  end
end
```

### Input Validation and Sanitization

```ruby
# app/controllers/tdx_feedback_gem/feedbacks_controller.rb
class TdxFeedbackGem::FeedbacksController < ApplicationController
  before_action :sanitize_input

  private

  def sanitize_input
    # Sanitize feedback parameters
    if params[:feedback]
      params[:feedback][:message] = sanitize_text(params[:feedback][:message])
      params[:feedback][:context] = sanitize_text(params[:feedback][:context])
    end
  end

  def sanitize_text(text)
    return nil if text.blank?

    # Remove potentially dangerous HTML
    ActionController::Base.helpers.sanitize(text, tags: %w[strong em u])
  end
end
```

### Rate Limiting

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Rate limit feedback submissions
  throttle('feedback_submissions', limit: 10, period: 1.minute) do |req|
    if req.path == '/tdx_feedback_gem/feedbacks' && req.post?
      req.ip
    end
  end

  # Rate limit modal requests
  throttle('modal_requests', limit: 30, period: 1.minute) do |req|
    if req.path == '/tdx_feedback_gem/feedbacks/new'
      req.ip
    end
  end

  # Block suspicious IPs
  blocklist('block suspicious IPs') do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 5, findtime: 10.minutes, bantime: 1.hour) do
      req.path == '/tdx_feedback_gem/feedbacks' && req.post?
    end
  end
end
```

### Authentication and Authorization

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :check_user_permissions

  private

  def check_user_permissions
    unless current_user.can_submit_feedback?
      render json: { error: 'Insufficient permissions' }, status: :forbidden
    end
  end
end

# app/models/user.rb
class User < ApplicationRecord
  def can_submit_feedback?
    # Implement your permission logic
    active? && !banned? && feedback_count_today < 5
  end

  def feedback_count_today
    feedbacks.where('created_at >= ?', Time.current.beginning_of_day).count
  end
end
```

## 📊 Monitoring and Logging

### Application Monitoring

```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  config.traces_sample_rate = 0.1
  config.profiles_sample_rate = 0.1

  # Filter sensitive data
  config.before_send = lambda do |event, hint|
    # Remove sensitive information
    event.request.data&.delete('password')
    event.request.data&.delete('client_secret')
    event
  end
end

# config/initializers/new_relic.rb
if defined?(NewRelic)
  NewRelic::Agent.config[:app_name] = ENV['NEW_RELIC_APP_NAME']
  NewRelic::Agent.config[:license_key] = ENV['NEW_RELIC_LICENSE_KEY']
  NewRelic::Agent.config[:log_level] = 'info'
end
```

### Custom Metrics

```ruby
# app/models/concerns/feedback_metrics.rb
module FeedbackMetrics
  extend ActiveSupport::Concern

  included do
    after_create :track_feedback_metrics
    after_update :track_feedback_update_metrics
  end

  private

  def track_feedback_metrics
    # Track feedback creation
    if defined?(StatsD)
      StatsD.increment('feedback.created')
      StatsD.timing('feedback.creation_time', created_at - Time.current)
    end

    # Track TDX ticket creation
    if tdx_ticket_id.present?
      StatsD.increment('feedback.tdx_ticket_created')
    end
  end

  def track_feedback_update_metrics
    if defined?(StatsD)
      StatsD.increment('feedback.updated')
    end
  end
end

# app/controllers/tdx_feedback_gem/feedbacks_controller.rb
class TdxFeedbackGem::FeedbacksController < ApplicationController
  around_action :track_performance

  private

  def track_performance
    start_time = Time.current

    yield

    duration = ((Time.current - start_time) * 1000).round

    if defined?(StatsD)
      StatsD.timing('feedback.controller.#{action_name}', duration)
    end

    # Log slow requests
    if duration > 1000
      Rails.logger.warn("Slow feedback request: #{action_name} took #{duration}ms")
    end
  end
end
```

### Health Checks

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Health check endpoints
  get '/health', to: 'health#check'
  get '/health/tdx', to: 'health#tdx'
  get '/health/database', to: 'health#database'
end

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def check
    render json: {
      status: 'healthy',
      timestamp: Time.current.iso8601,
      version: TdxFeedbackGem::VERSION
    }
  end

  def tdx
    begin
      # Test TDX connection
      client = TdxFeedbackGem::Client.instance
      client.test_connection

      render json: { status: 'healthy', service: 'tdx' }
    rescue => e
      render json: { status: 'unhealthy', service: 'tdx', error: e.message }, status: :service_unavailable
    end
  end

  def database
    begin
      # Test database connection
      TdxFeedbackGem::Feedback.count

      render json: { status: 'healthy', service: 'database' }
    rescue => e
      render json: { status: 'unhealthy', service: 'database', error: e.message }, status: :service_unavailable
    end
  end
end
```

## 🗄️ Database Configuration

### Production Database Setup

```yaml
# config/database.yml
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['DATABASE_NAME'] %>
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>
  port: <%= ENV['DATABASE_PORT'] || 5432 %>

  # Connection pool settings
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  checkout_timeout: 5
  reaping_frequency: 10

  # SSL configuration
  sslmode: require

  # Statement timeout
  variables:
    statement_timeout: 5000
    lock_timeout: 1000
    idle_in_transaction_session_timeout: 60000
```

### Database Maintenance

```ruby
# lib/tasks/database_maintenance.rake
namespace :db do
  namespace :maintenance do
    desc "Optimize feedback table"
    task optimize_feedback: :environment do
      puts "Optimizing feedback table..."

      if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
        # Vacuum and analyze
        ActiveRecord::Base.connection.execute("VACUUM ANALYZE tdx_feedback_gem_feedbacks")

        # Update statistics
        ActiveRecord::Base.connection.execute("ANALYZE tdx_feedback_gem_feedbacks")

        # Reindex if needed
        ActiveRecord::Base.connection.execute("REINDEX TABLE tdx_feedback_gem_feedbacks")
      elsif ActiveRecord::Base.connection.adapter_name.downcase == 'mysql2'
        # Optimize table
        ActiveRecord::Base.connection.execute("OPTIMIZE TABLE tdx_feedback_gem_feedbacks")

        # Analyze table
        ActiveRecord::Base.connection.execute("ANALYZE TABLE tdx_feedback_gem_feedbacks")
      end

      puts "Feedback table optimization complete"
    end

    desc "Clean up old feedback data"
    task cleanup_old_feedback: :environment do
      puts "Cleaning up old feedback data..."

      # Delete feedback older than 2 years without TDX tickets
      cutoff_date = 2.years.ago
      old_feedback = TdxFeedbackGem::Feedback
        .where('created_at < ? AND tdx_ticket_id IS NULL', cutoff_date)

      count = old_feedback.count
      old_feedback.destroy_all

      puts "Cleaned up #{count} old feedback records"
    end

    desc "Backup feedback data"
    task backup_feedback: :environment do
      puts "Backing up feedback data..."

      # Export to CSV
      csv_data = FeedbackExporter.export_to_csv

      # Save to file
      timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
      filename = "feedback_backup_#{timestamp}.csv"
      filepath = Rails.root.join('tmp', filename)

      File.write(filepath, csv_data)

      puts "Feedback backup saved to #{filepath}"
    end
  end
end
```

## 🚀 Deployment Strategies

### Capistrano Deployment

```ruby
# config/deploy.rb
set :application, 'your_app_name'
set :repo_url, 'git@github.com:username/your_app.git'
set :branch, 'main'

set :deploy_to, '/var/www/your_app'
set :deploy_user, 'deploy'

set :linked_files, %w{config/database.yml config/master.key .env.production}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets}

set :rbenv_ruby, '3.1.0'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

set :puma_init_active_record, true

# TDX Feedback Gem specific tasks
namespace :deploy do
  namespace :tdx_feedback do
    desc "Restart TDX Feedback Gem services"
    task :restart do
      on roles(:app) do
        within current_path do
          execute :bundle, "exec rails tdx_feedback:restart"
        end
      end
    end

    desc "Run TDX Feedback Gem migrations"
    task :migrate do
      on roles(:db) do
        within current_path do
          execute :bundle, "exec rails tdx_feedback:migrate"
        end
      end
    end
  end
end

after 'deploy:published', 'deploy:tdx_feedback:restart'
```

### Docker Deployment

```dockerfile
# Dockerfile
FROM ruby:3.1-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    yarn \
    tzdata

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# Create non-root user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
USER app

# Expose port
EXPOSE 3000

# Start application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/your_app_production
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./tmp:/app/tmp
      - ./log:/app/log

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=your_app_production
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Kubernetes Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tdx-feedback-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: tdx-feedback-app
  template:
    metadata:
      labels:
        app: tdx-feedback-app
    spec:
      containers:
      - name: app
        image: your-registry/tdx-feedback-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: RAILS_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: TDX_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: tdx-client-secret
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

## 📈 Scaling Considerations

### Horizontal Scaling

```ruby
# config/application.rb
class Application < Rails::Application
  # Enable session store for multiple servers
  config.session_store :redis_store, {
    servers: [
      { host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'], db: 1 },
      { host: ENV['REDIS_HOST_2'], port: ENV['REDIS_PORT'], db: 1 }
    ],
    key: '_your_app_session',
    expire_after: 90.minutes
  }

  # Enable fragment caching across servers
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    connect_timeout: 30,
    read_timeout: 0.2,
    write_timeout: 0.2,
    error_handler: -> (method:, returning:, exception:) {
      Sentry.capture_exception(exception, level: :warning, tags: { method: method, returning: returning })
    }
  }
end
```

### Load Balancing

```nginx
# nginx.conf
upstream tdx_feedback_app {
  server 127.0.0.1:3000;
  server 127.0.0.1:3001;
  server 127.0.0.1:3002;
}

server {
  listen 80;
  server_name your-domain.com;

  location / {
    proxy_pass http://tdx_feedback_app;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  # Health check endpoint
  location /health {
    proxy_pass http://tdx_feedback_app;
    access_log off;
  }
}
```

### Background Job Processing

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }

  # Configure concurrency
  config.concurrency = ENV.fetch('SIDEKIQ_CONCURRENCY', 10).to_i

  # Configure queues
  config.queues = %w[default feedback tdx_tickets]
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

# app/jobs/tdx_ticket_creation_job.rb
class TdxTicketCreationJob < ApplicationJob
  queue_as :tdx_tickets

  def perform(feedback_id)
    feedback = TdxFeedbackGem::Feedback.find(feedback_id)

    begin
      client = TdxFeedbackGem::Client.instance
      result = client.create_ticket(feedback)

      if result.success?
        feedback.update!(tdx_ticket_id: result.ticket_id)
        StatsD.increment('tdx_ticket.created')
      else
        StatsD.increment('tdx_ticket.failed')
        raise "Failed to create TDX ticket: #{result.error}"
      end
    rescue => e
      StatsD.increment('tdx_ticket.error')
      Sentry.capture_exception(e, extra: { feedback_id: feedback_id })

      # Retry with exponential backoff
      retry_job wait: exponential_backoff(executions)
    end
  end

  private

  def exponential_backoff(executions)
    [2 ** executions, 30].min.minutes
  end
end
```

## 🔄 Maintenance and Updates

### Automated Backups

```ruby
# lib/tasks/backup.rake
namespace :backup do
  desc "Create automated backup of feedback data"
  task feedback: :environment do
    puts "Creating feedback backup..."

    # Export feedback data
    csv_data = FeedbackExporter.export_to_csv

    # Compress data
    require 'zlib'
    compressed_data = Zlib::Deflate.deflate(csv_data)

    # Save to backup location
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "feedback_backup_#{timestamp}.csv.gz"
    backup_path = Rails.root.join('backups', filename)

    FileUtils.mkdir_p(File.dirname(backup_path))
    File.binwrite(backup_path, compressed_data)

    # Upload to cloud storage (optional)
    if defined?(Aws::S3)
      upload_to_s3(backup_path, filename)
    end

    # Clean up old backups
    cleanup_old_backups

    puts "Backup completed: #{backup_path}"
  end

  private

  def upload_to_s3(file_path, filename)
    s3_client = Aws::S3::Client.new
    s3_client.put_object(
      bucket: ENV['BACKUP_BUCKET'],
      key: "feedback_backups/#{filename}",
      body: File.read(file_path)
    )
  end

  def cleanup_old_backups
    backup_dir = Rails.root.join('backups')
    return unless Dir.exist?(backup_dir)

    # Keep only last 30 backups
    backups = Dir.glob(backup_dir.join('feedback_backup_*.csv.gz'))
      .sort_by { |f| File.mtime(f) }
      .reverse

    if backups.length > 30
      backups[30..-1].each do |backup|
        File.delete(backup)
        puts "Deleted old backup: #{backup}"
      end
    end
  end
end
```

### Health Monitoring

```ruby
# config/initializers/health_monitoring.rb
class HealthMonitor
  def self.check_all
    results = {
      database: check_database,
      tdx_api: check_tdx_api,
      redis: check_redis,
      assets: check_assets
    }

    overall_status = results.values.all? { |r| r[:status] == 'healthy' } ? 'healthy' : 'unhealthy'

    {
      status: overall_status,
      timestamp: Time.current.iso8601,
      services: results
    }
  end

  private

  def self.check_database
    start_time = Time.current

    begin
      TdxFeedbackGem::Feedback.count
      duration = ((Time.current - start_time) * 1000).round

      {
        status: 'healthy',
        response_time: duration,
        timestamp: Time.current.iso8601
      }
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        timestamp: Time.current.iso8601
      }
    end
  end

  def self.check_tdx_api
    start_time = Time.current

    begin
      client = TdxFeedbackGem::Client.instance
      client.test_connection

      duration = ((Time.current - start_time) * 1000).round

      {
        status: 'healthy',
        response_time: duration,
        timestamp: Time.current.iso8601
      }
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        timestamp: Time.current.iso8601
      }
    end
  end

  def self.check_redis
    start_time = Time.current

    begin
      Rails.cache.write('health_check', 'ok', expires_in: 1.minute)
      value = Rails.cache.read('health_check')

      duration = ((Time.current - start_time) * 1000).round

      if value == 'ok'
        {
          status: 'healthy',
          response_time: duration,
          timestamp: Time.current.iso8601
        }
      else
        {
          status: 'unhealthy',
          error: 'Cache read/write mismatch',
          timestamp: Time.current.iso8601
        }
      end
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        timestamp: Time.current.iso8601
      }
    end
  end

  def self.check_assets
    begin
      # Check if critical assets are accessible
      critical_assets = %w[tdx_feedback_gem.css tdx_feedback_gem.js]

      missing_assets = critical_assets.reject do |asset|
        Rails.application.assets.find_asset(asset).present?
      end

      if missing_assets.empty?
        {
          status: 'healthy',
          timestamp: Time.current.iso8601
        }
      else
        {
          status: 'unhealthy',
          error: "Missing assets: #{missing_assets.join(', ')}",
          timestamp: Time.current.iso8601
        }
      end
    rescue => e
      {
        status: 'unhealthy',
        error: e.message,
        timestamp: Time.current.iso8601
      }
    end
  end
end
```

## 🔄 Next Steps

Now that you understand production deployment:

1. **[Performance Optimization](Performance-Optimization)** - Optimize your production deployment
2. **[Testing Guide](Testing)** - Test your production setup
3. **[Database Schema](Database-Schema)** - Optimize your database for production
4. **[API Endpoints](API-Endpoints)** - Secure your API endpoints

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more details about performance optimization, see the [Performance Optimization](Performance-Optimization) guide.*
