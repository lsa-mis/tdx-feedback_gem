# Performance Optimization

Complete guide to optimizing the performance of the TDX Feedback Gem, covering assets, database, API calls, and overall application performance.

## 📊 Performance Overview

The TDX Feedback Gem is designed to be lightweight and fast, but there are several optimization strategies you can implement to ensure optimal performance in production environments.

## 🚀 Asset Optimization

### CSS Optimization

#### Minification and Compression

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Compress CSS using a preprocessor
  config.assets.css_compressor = :sass

  # Enable asset compression
  config.assets.compress = true

  # Precompile additional assets
  config.assets.precompile += %w( tdx_feedback_gem.css )
end
```

#### Critical CSS Inlining

```erb
<!-- Inline critical CSS for above-the-fold content -->
<style>
  /* Critical feedback modal styles */
  .tdx-feedback-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
  }

  .tdx-feedback-modal-overlay {
    background: rgba(0, 0, 0, 0.5);
  }
</style>

<!-- Load non-critical CSS asynchronously -->
<link rel="preload" href="<%= asset_path('tdx_feedback_gem.css') %>" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="<%= asset_path('tdx_feedback_gem.css') %>"></noscript>
```

#### CSS Purging

```javascript
// webpack.config.js (if using Webpacker)
const PurgecssPlugin = require('purgecss-webpack-plugin');
const glob = require('glob');

module.exports = {
  plugins: [
    new PurgecssPlugin({
      paths: glob.sync(`${path.join(__dirname, 'app')}/**/*`, { nodir: true }),
      safelist: ['tdx-feedback-modal', 'tdx-feedback-form']
    })
  ]
};
```

### JavaScript Optimization

#### Code Splitting

```javascript
// app/javascript/controllers/tdx_feedback_controller.js
// Lazy load the feedback controller only when needed
export const TdxFeedbackController = {
  async load() {
    const { default: Controller } = await import('./tdx_feedback_controller');
    return Controller;
  }
};

// Usage
document.addEventListener('click', async (event) => {
  if (event.target.matches('[data-feedback-trigger]')) {
    const Controller = await TdxFeedbackController.load();
    // Initialize controller
  }
});
```

#### Bundle Analysis

```bash
# Analyze bundle size
bundle exec rails assets:precompile
npx webpack-bundle-analyzer public/assets/manifest.json

# Or use Rails asset analyzer
gem 'rails-asset-analyzer'
```

#### Tree Shaking

```javascript
// Only import what you need
import { openModal, closeModal } from 'tdx_feedback_gem';

// Instead of
import * as TdxFeedback from 'tdx_feedback_gem';
```

### Asset Loading Strategies

#### Preloading Critical Resources

```erb
<!-- Preload critical assets -->
<link rel="preload" href="<%= asset_path('tdx_feedback_gem.js') %>" as="script">
<link rel="preload" href="<%= asset_path('tdx_feedback_gem.css') %>" as="style">

<!-- Prefetch non-critical assets -->
<link rel="prefetch" href="<%= asset_path('tdx_feedback_gem_icons.svg') %>">
```

#### Lazy Loading

```javascript
// Lazy load feedback modal
class FeedbackLazyLoader {
  constructor() {
    this.loaded = false;
    this.loading = false;
  }

  async loadModal() {
    if (this.loaded) return;
    if (this.loading) return;

    this.loading = true;

    try {
      const response = await fetch('/tdx_feedback_gem/feedbacks/new', {
        headers: { 'Accept': 'application/json' }
      });

      const data = await response.json();
      if (data.success) {
        document.body.insertAdjacentHTML('beforeend', data.html);
        this.loaded = true;
      }
    } catch (error) {
      console.error('Failed to load feedback modal:', error);
    } finally {
      this.loading = false;
    }
  }
}

// Usage
const feedbackLoader = new FeedbackLazyLoader();
document.addEventListener('click', (event) => {
  if (event.target.matches('[data-feedback-trigger]')) {
    feedbackLoader.loadModal();
  }
});
```

## 🗄️ Database Optimization

### Query Optimization

#### N+1 Query Prevention

```ruby
# Bad: N+1 queries
feedbacks = TdxFeedbackGem::Feedback.recent.limit(20)
feedbacks.each { |f| puts f.user.email }  # N+1 problem

# Good: Eager loading
feedbacks = TdxFeedbackGem::Feedback.includes(:user).recent.limit(20)
feedbacks.each { |f| puts f.user.email }  # Single query
```

#### Database Indexes

```ruby
# Add performance indexes
class AddPerformanceIndexesToTdxFeedbackGemFeedbacks < ActiveRecord::Migration[6.1]
  def change
    # Composite index for common queries
    add_index :tdx_feedback_gem_feedbacks, [:user_id, :created_at]

    # Partial index for TDX tickets
    add_index :tdx_feedback_gem_feedbacks, :tdx_ticket_id,
              where: "tdx_ticket_id IS NOT NULL"

    # Text search index (PostgreSQL)
    add_index :tdx_feedback_gem_feedbacks, :message,
              using: :gin,
              opclass: :gin_trgm_ops
  end
end
```

#### Query Caching

```ruby
# Cache expensive queries
class FeedbackAnalytics
  def self.feedback_count_by_date(days = 30)
    Rails.cache.fetch("feedback_count_by_date_#{days}", expires_in: 1.hour) do
      TdxFeedbackGem::Feedback
        .where('created_at >= ?', days.days.ago)
        .group("DATE(created_at)")
        .count
    end
  end

  def self.top_feedback_types
    Rails.cache.fetch("top_feedback_types", expires_in: 2.hours) do
      TdxFeedbackGem::Feedback
        .where.not(context: [nil, ''])
        .group(:context)
        .count
        .sort_by { |_, count| -count }
        .first(10)
    end
  end
end
```

### Connection Pooling

```ruby
# config/database.yml
production:
  adapter: postgresql
  database: your_app_production
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

  # Connection pool settings
  checkout_timeout: 5
  reaping_frequency: 10

  # Statement timeout
  variables:
    statement_timeout: 5000
    lock_timeout: 1000
```

### Database Maintenance

```ruby
# Regular maintenance tasks
namespace :feedback do
  desc "Optimize feedback table"
  task optimize: :environment do
    puts "Optimizing feedback table..."

    # Vacuum and analyze (PostgreSQL)
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      ActiveRecord::Base.connection.execute("VACUUM ANALYZE tdx_feedback_gem_feedbacks")
    end

    # Optimize table (MySQL)
    if ActiveRecord::Base.connection.adapter_name.downcase == 'mysql2'
      ActiveRecord::Base.connection.execute("OPTIMIZE TABLE tdx_feedback_gem_feedbacks")
    end

    puts "Table optimization complete"
  end

  desc "Update table statistics"
  task stats: :environment do
    puts "Updating table statistics..."

    # Update statistics for query planner
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      ActiveRecord::Base.connection.execute("ANALYZE tdx_feedback_gem_feedbacks")
    end

    if ActiveRecord::Base.connection.adapter_name.downcase == 'mysql2'
      ActiveRecord::Base.connection.execute("ANALYZE TABLE tdx_feedback_gem_feedbacks")
    end

    puts "Statistics updated"
  end
end
```

## 🌐 API Optimization

### TDX API Calls

#### Connection Pooling

```ruby
# lib/tdx_feedback_gem/client.rb
class TdxFeedbackGem::Client
  include Singleton

  def initialize
    @connection_pool = ConnectionPool.new(size: 5, timeout: 5) do
      Net::HTTP.new(uri.host, uri.port)
    end
  end

  def create_ticket(feedback)
    @connection_pool.with do |http|
      # Use pooled connection
      request = build_request(feedback)
      response = http.request(request)
      parse_response(response)
    end
  end

  private

  def uri
    @uri ||= URI(TdxFeedbackGem.configuration.tdx_base_url)
  end
end
```

#### Request Batching

```ruby
# Batch multiple feedback submissions
class FeedbackBatchProcessor
  def self.process_batch(feedbacks, batch_size = 10)
    feedbacks.each_slice(batch_size).map do |batch|
      batch.map { |feedback| create_ticket_async(feedback) }
    end.flatten
  end

  private

  def self.create_ticket_async(feedback)
    Thread.new do
      TdxFeedbackGem::Client.instance.create_ticket(feedback)
    end
  end
end
```

#### Caching and Retry Logic

```ruby
# Cache OAuth tokens
class TdxFeedbackGem::Client
  def oauth_token
    Rails.cache.fetch('tdx_oauth_token', expires_in: 3500) do
      # Token expires in 1 hour, refresh after 58 minutes
      fetch_new_token
    end
  end

  def create_ticket_with_retry(feedback, max_retries = 3)
    retries = 0

    begin
      create_ticket(feedback)
    rescue => e
      retries += 1

      if retries <= max_retries
        sleep(2 ** retries) # Exponential backoff
        retry
      else
        raise e
      end
    end
  end
end
```

### HTTP Optimization

#### Keep-Alive Connections

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.http_keep_alive = true
  config.http_timeout = 30
  config.http_open_timeout = 10
end
```

#### Request Compression

```ruby
# Enable gzip compression for API requests
class TdxFeedbackGem::Client
  def build_request(feedback)
    request = Net::HTTP::Post.new(uri.path)
    request['Accept-Encoding'] = 'gzip, deflate'
    request['Content-Type'] = 'application/json'
    request.body = feedback.to_json
    request
  end
end
```

## 📱 Frontend Performance

### Modal Loading Optimization

#### Progressive Enhancement

```javascript
// Load modal progressively
class ProgressiveFeedbackModal {
  constructor() {
    this.modal = null;
    this.loaded = false;
  }

  async show() {
    if (!this.loaded) {
      await this.loadModal();
    }

    this.modal.classList.add('show');
  }

  async loadModal() {
    // Show loading state
    this.showLoadingState();

    try {
      const response = await fetch('/tdx_feedback_gem/feedbacks/new');
      const html = await response.text();

      // Insert modal
      document.body.insertAdjacentHTML('beforeend', html);
      this.modal = document.querySelector('.tdx-feedback-modal');
      this.loaded = true;

      // Initialize Stimulus controller
      this.initializeController();
    } catch (error) {
      this.showErrorState();
    }
  }

  showLoadingState() {
    // Show loading indicator
  }

  showErrorState() {
    // Show error message
  }
}
```

#### Virtual Scrolling (for large feedback lists)

```javascript
// Virtual scrolling for feedback management
class VirtualFeedbackList {
  constructor(container, itemHeight = 60) {
    this.container = container;
    this.itemHeight = itemHeight;
    this.items = [];
    this.visibleItems = [];
    this.scrollTop = 0;

    this.setupVirtualScrolling();
  }

  setupVirtualScrolling() {
    this.container.addEventListener('scroll', this.handleScroll.bind(this));
    this.render();
  }

  handleScroll() {
    this.scrollTop = this.container.scrollTop;
    this.render();
  }

  render() {
    const startIndex = Math.floor(this.scrollTop / this.itemHeight);
    const endIndex = Math.min(
      startIndex + Math.ceil(this.container.clientHeight / this.itemHeight),
      this.items.length
    );

    this.renderVisibleItems(startIndex, endIndex);
  }

  renderVisibleItems(start, end) {
    // Render only visible items
  }
}
```

### Form Performance

#### Debounced Input

```javascript
// Debounce form input for better performance
class DebouncedFeedbackForm {
  constructor(form) {
    this.form = form;
    this.debounceTimer = null;
    this.setupDebouncing();
  }

  setupDebouncing() {
    const inputs = this.form.querySelectorAll('input, textarea');

    inputs.forEach(input => {
      input.addEventListener('input', (event) => {
        clearTimeout(this.debounceTimer);
        this.debounceTimer = setTimeout(() => {
          this.handleInput(event);
        }, 300);
      });
    });
  }

  handleInput(event) {
    // Handle input changes
    this.validateField(event.target);
    this.autoSave();
  }

  validateField(field) {
    // Real-time validation
  }

  autoSave() {
    // Auto-save draft
  }
}
```

#### Form Validation Optimization

```javascript
// Optimized form validation
class OptimizedFeedbackValidator {
  constructor(form) {
    this.form = form;
    this.validationCache = new Map();
    this.setupValidation();
  }

  setupValidation() {
    // Use event delegation for better performance
    this.form.addEventListener('input', this.handleValidation.bind(this));
  }

  handleValidation(event) {
    const field = event.target;
    const fieldName = field.name;

    // Check cache first
    if (this.validationCache.has(fieldName)) {
      const cached = this.validationCache.get(fieldName);
      if (cached.value === field.value) {
        return; // Skip validation if value hasn't changed
      }
    }

    // Perform validation
    const validation = this.validateField(field);

    // Cache result
    this.validationCache.set(fieldName, {
      value: field.value,
      validation: validation
    });

    // Show validation result
    this.showValidationResult(field, validation);
  }

  validateField(field) {
    // Field-specific validation logic
    const rules = this.getValidationRules(field);
    return this.applyRules(field.value, rules);
  }
}
```

## 📊 Monitoring and Metrics

### Performance Monitoring

#### Response Time Tracking

```ruby
# Track API response times
class FeedbackPerformanceTracker
  def self.track_api_call(endpoint, duration)
    Rails.logger.info("API Call: #{endpoint} took #{duration}ms")

    # Send to monitoring service
    if defined?(StatsD)
      StatsD.timing("tdx_feedback.api.#{endpoint}", duration)
    end

    # Store in database for analysis
    ApiCallLog.create(
      endpoint: endpoint,
      duration: duration,
      timestamp: Time.current
    )
  end
end

# Usage in client
class TdxFeedbackGem::Client
  def create_ticket(feedback)
    start_time = Time.current

    begin
      result = perform_create_ticket(feedback)
      duration = ((Time.current - start_time) * 1000).round
      FeedbackPerformanceTracker.track_api_call('create_ticket', duration)
      result
    rescue => e
      duration = ((Time.current - start_time) * 1000).round
      FeedbackPerformanceTracker.track_api_call('create_ticket_error', duration)
      raise e
    end
  end
end
```

#### Database Query Monitoring

```ruby
# Monitor slow queries
class SlowQueryLogger
  def self.log_slow_query(sql, duration, backtrace)
    return if duration < 100 # Only log queries slower than 100ms

    Rails.logger.warn("Slow Query (#{duration}ms): #{sql}")

    # Send to monitoring service
    if defined?(Sentry)
      Sentry.capture_message("Slow Query Detected",
        extra: { sql: sql, duration: duration, backtrace: backtrace }
      )
    end
  end
end

# Configure in application.rb
config.after_initialize do
  ActiveRecord::Base.logger = SlowQueryLogger.new
end
```

### Performance Testing

#### Load Testing

```ruby
# spec/performance/feedback_performance_spec.rb
require 'rails_helper'

RSpec.describe 'Feedback Performance', type: :performance do
  it 'handles concurrent feedback submissions' do
    expect {
      threads = 20.times.map do
        Thread.new do
          post '/tdx_feedback_gem/feedbacks', params: {
            feedback: { message: "Performance test #{rand(1000)}" }
          }
        end
      end

      threads.each(&:join)
    }.to change(TdxFeedbackGem::Feedback, :count).by(20)
  end

  it 'modal loads within performance budget' do
    start_time = Time.current

    get '/tdx_feedback_gem/feedbacks/new'

    duration = ((Time.current - start_time) * 1000).round
    expect(duration).to be < 100 # Should load in under 100ms
  end
end
```

#### Memory Profiling

```ruby
# Memory usage monitoring
class MemoryProfiler
  def self.profile_memory
    initial_memory = GetProcessMem.new.mb

    yield

    final_memory = GetProcessMem.new.mb
    memory_increase = final_memory - initial_memory

    Rails.logger.info("Memory usage: #{memory_increase}MB")
    memory_increase
  end
end

# Usage
MemoryProfiler.profile_memory do
  100.times do
    post '/tdx_feedback_gem/feedbacks', params: {
      feedback: { message: "Memory test #{rand(1000)}" }
    }
  end
end
```

## 🔧 Configuration Optimization

### Environment-Specific Settings

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Asset optimization
  config.assets.compile = false
  config.assets.js_compressor = :terser
  config.assets.css_compressor = :sass

  # Database optimization
  config.active_record.dump_schema_after_migration = false

  # Cache optimization
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    connect_timeout: 30,
    read_timeout: 0.2,
    write_timeout: 0.2
  }

  # Logging optimization
  config.log_level = :warn
  config.log_tags = [:request_id]
end
```

### Gem-Specific Configuration

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  # Performance settings
  config.enable_caching = true
  config.cache_duration = 1.hour
  config.enable_compression = true

  # API optimization
  config.http_timeout = 30
  config.http_keep_alive = true
  config.enable_retry = true
  config.max_retries = 3

  # Database optimization
  config.batch_size = 100
  config.enable_counter_cache = true
end
```

## 🔄 Next Steps

Now that you understand performance optimization:

1. **[Production Deployment](Production-Deployment.md)** - Deploy with optimized performance
2. **[Testing Guide](Testing)** - Test your performance optimizations
3. **[Database Schema](Database-Schema.md)** - Optimize your database structure
4. **[API Endpoints](API-Endpoints.md)** - Optimize your API performance

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting.md)
- Review [Configuration Guide](Configuration-Guide.md) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more details about production deployment, see the [Production Deployment](Production-Deployment.md) guide.*
