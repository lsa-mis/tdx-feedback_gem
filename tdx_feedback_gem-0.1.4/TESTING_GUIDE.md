# Testing Guide for TdxFeedbackGem

This guide outlines the best practices for testing the TdxFeedbackGem during development and before release.

## Testing Strategy Overview

### 1. **Dummy App Testing (Primary Development Method)**

- **Best for**: Daily development, unit tests, integration tests
- **Location**: `spec/dummy/` directory
- **Speed**: Fast
- **Isolation**: Complete

### 2. **Real Application Testing (Integration Validation)**

- **Best for**: Final validation, real-world scenarios
- **Location**: External Rails applications
- **Speed**: Slower but more realistic
- **Isolation**: Limited (affects real app)

## Testing Workflows

### Daily Development Testing

```bash
# Run all tests in the dummy app
bundle exec rspec

# Run specific test categories
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
bundle exec rspec spec/requests/
bundle exec rspec spec/helpers/

# Test the install generator
bundle exec rspec spec/requests/install_generator_spec.rb
```

### Install Generator Testing

```bash
# Test generator in dummy app
cd spec/dummy
rails generate tdx_feedback_gem:install
rails db:migrate
rails server

# Verify files were created correctly
ls -la config/initializers/tdx_feedback_gem.rb
ls -la app/javascript/controllers/tdx_feedback_controller.js
ls -la app/assets/stylesheets/_tdx_feedback_gem.scss
```

### Real Application Testing

```bash
# In your test application
git checkout -b test-tdx-feedback-gem

# Add to Gemfile
echo "gem 'tdx_feedback_gem', path: '/path/to/your/gem'" >> Gemfile

# Install and test
bundle install
rails generate tdx_feedback_gem:install
rails db:migrate
rails server

# Test the functionality
# Visit your app and test the feedback forms
```

## Test Categories

### 1. **Unit Tests**

- Model validations and methods
- Controller actions
- Helper methods
- Configuration options

### 2. **Integration Tests**

- Request flows (form submission, AJAX calls)
- Database operations
- Asset compilation
- JavaScript functionality
  - Importmap auto-pin behavior (see `spec/integration/importmap_auto_pin_spec.rb`)

### 3. **Generator Tests**

- File creation
- Content validation
- Asset inclusion
- Migration generation

### 4. **Real Application Tests**

- Full installation process
- Asset pipeline integration
- JavaScript loading
- Database migrations

## Best Practices

### For Development

1. **Use the dummy app for 90% of testing**
   - It's faster and more isolated
   - Perfect for iterative development
   - No risk of affecting real applications

2. **Run tests frequently**

   ```bash
   bundle exec rspec --watch  # Auto-rerun on file changes
   ```

3. **Test the generator after changes**

   ```bash
   cd spec/dummy
   rails generate tdx_feedback_gem:install --force
   ```

4. **Validate Importmap auto-pin (drop-in assurance)**
   The gem auto-pins its Stimulus controller for Importmap users when `auto_pin_importmap` is enabled (default). The dedicated spec ensures:
   - The controller is pinned exactly once
   - Re-running the initializer is idempotent (no duplicate pin entries)

   Run just this spec:

   ```bash
   bundle exec rspec spec/integration/importmap_auto_pin_spec.rb
   ```

   Troubleshooting:
   - If the spec is skipped or fails due to missing Importmap constants, ensure `importmap-rails` is in your development/test dependencies.
   - The spec emulates minimal Importmap behavior if the full railtie isn't active, so a green test indicates the engine initializer logic is functioning.

### For Release Preparation

1. **Test in multiple Rails versions**
   - Create test apps with different Rails versions
   - Test with both SCSS and CSS setups
   - Test with different JavaScript setups (importmaps, esbuild, etc.)

2. **Test in real applications**
   - Use your existing applications as test beds
   - Test with different asset configurations
   - Verify no conflicts with existing code

3. **Test edge cases**
   - Applications without JavaScript
   - Applications without stylesheets
   - Applications with existing feedback systems

## Troubleshooting Common Issues

### Generator Not Working

```bash
# Check if generator is properly registered
rails generate --help | grep tdx_feedback_gem

# Check generator source
ls -la lib/generators/tdx_feedback_gem/install/
```

### Assets Not Loading

```bash
# Check asset paths
ls -la app/assets/stylesheets/
ls -la app/javascript/controllers/

# Check application files
cat app/assets/stylesheets/application.scss
cat app/javascript/application.js
```

### Database Issues

```bash
# Check migration
rails db:migrate:status
rails db:rollback
rails db:migrate

# Check table structure
rails dbconsole
# Then: \d tdx_feedback_gem_feedbacks
```

## Continuous Integration

For CI/CD, focus on the dummy app tests:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    bundle exec rspec
    cd spec/dummy
    rails generate tdx_feedback_gem:install
    rails db:migrate
    bundle exec rspec
```

## Performance Testing

```bash
# Test asset compilation time
time rails assets:precompile

# Test database query performance
rails console
# Then run performance tests on your models
```

## Security Testing

- Test authentication requirements
- Validate input sanitization
- Check for SQL injection vulnerabilities
- Test CSRF protection

## Browser Testing

For JavaScript functionality:

- Test in multiple browsers
- Test with JavaScript disabled
- Test on mobile devices
- Test accessibility features

## Recommended Testing Schedule

### Daily Development

- Run unit tests before committing
- Test generator after changes
- Run integration tests before pushing

### Weekly

- Test in dummy app with fresh install
- Run full test suite
- Check for regressions

### Before Release

- Test in real applications
- Test with different Rails versions
- Test with different asset configurations
- Performance testing
- Security audit

## Conclusion

The combination of dummy app testing for development and real application testing for validation provides the best balance of speed and reliability. Use the dummy app for most of your development work, and reserve real application testing for final validation before releases.
