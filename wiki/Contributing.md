# Contributing Guidelines

Complete guide to contributing to the TDX Feedback Gem project.

## 🤝 Welcome Contributors!

Thank you for your interest in contributing to the TDX Feedback Gem! This project thrives on community contributions, and we welcome developers of all skill levels.

## 📋 Before You Start

### Prerequisites

- **Ruby 2.6+** (recommended: Ruby 3.0+)
- **Rails 5.2+** (tested with Rails 5.2, 6.x, and 7.x)
- **Git** - for version control
- **Basic understanding** of Rails engines and gems

### What We're Looking For

- **Bug fixes** - Help squash bugs and improve stability
- **Feature enhancements** - Add new functionality
- **Documentation improvements** - Better guides and examples
- **Testing improvements** - Better test coverage and quality
- **Performance optimizations** - Make the gem faster and more efficient

## 🚀 Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/tdx-feedback_gem.git
cd tdx-feedback_gem

# Add the original repository as upstream
git remote add upstream https://github.com/lsa-mis/tdx-feedback_gem.git
```

### 2. Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies (if any)
yarn install
```

### 3. Setup Test Environment

```bash
# Create test database
cd spec/dummy
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:test:prepare
cd ../..
```

### 4. Run Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/configuration_spec.rb
bundle exec rspec spec/client_spec.rb

# Run tests with coverage
COVERAGE=true bundle exec rspec
```

## 🔧 Development Workflow

### 1. Create a Feature Branch

```bash
# Always work on a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/issue-description
```

**Branch Naming Conventions**:
- `feature/descriptive-name` - New features
- `fix/issue-description` - Bug fixes
- `docs/description` - Documentation updates
- `test/description` - Test improvements
- `refactor/description` - Code refactoring

### 2. Make Your Changes

#### Code Style Guidelines

**Ruby Code**:
```ruby
# Use 2 spaces for indentation
class TdxFeedbackGem::Configuration
  def initialize
    @options = {}
  end

  # Use snake_case for methods and variables
  def enable_ticket_creation
    @options[:enable_ticket_creation]
  end

  # Use descriptive method names
  def enable_ticket_creation=(value)
    @options[:enable_ticket_creation] = value
  end
end
```

**JavaScript Code**:
```javascript
// Use 2 spaces for indentation
class TdxFeedbackController extends Controller {
  static targets = ["modal", "form"]

  // Use camelCase for methods and variables
  connect() {
    this.setupEventListeners()
  }

  // Use descriptive method names
  setupEventListeners() {
    this.element.addEventListener('click', this.openModal.bind(this))
  }
}
```

**CSS Code**:
```css
/* Use 2 spaces for indentation */
.tdx-feedback-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

/* Use kebab-case for class names */
.tdx-feedback-modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
```

#### Testing Requirements

**All changes must include tests**:

```ruby
# spec/configuration_spec.rb
RSpec.describe TdxFeedbackGem::Configuration do
  describe '#enable_ticket_creation=' do
    it 'sets the enable_ticket_creation option' do
      config = described_class.new
      config.enable_ticket_creation = true
      expect(config.enable_ticket_creation).to be true
    end
  end
end
```

**Test Coverage**:
- Maintain at least 90% test coverage
- Write tests for both success and failure scenarios
- Include integration tests for new features

### 3. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "Add feature: descriptive feature description

- Detailed bullet point about what was added
- Another bullet point about implementation details
- Fixes #123 (if applicable)"
```

**Commit Message Format**:
```
Type: Short description (50 chars or less)

More detailed explanatory text. Wrap it to about 72
characters or so. The blank line separating the summary
from the body is critical.

- Bullet points are okay, too
- Typically a hyphen or asterisk is used for the bullet,
  preceded by a single space, with blank lines in
  between, but conventions vary here

Fixes #123
```

**Commit Types**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### 4. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Go to GitHub and create a Pull Request
```

## 📝 Pull Request Process

### 1. Create the Pull Request

- **Title**: Clear, descriptive title
- **Description**: Detailed description of changes
- **Fixes**: Link to any related issues
- **Screenshots**: If UI changes are involved

### 2. Pull Request Template

```markdown
## Description
Brief description of what this PR accomplishes.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Checklist
- [ ] I have updated the documentation accordingly
- [ ] I have added tests to cover my changes
- [ ] All new and existing tests pass
- [ ] My changes generate no new warnings
- [ ] I have checked my code and corrected any misspellings

## Additional Notes
Any additional information that reviewers should know.
```

### 3. Review Process

**Code Review Checklist**:
- [ ] Code follows project style guidelines
- [ ] Tests are included and pass
- [ ] Documentation is updated
- [ ] No breaking changes (unless intentional)
- [ ] Performance considerations addressed
- [ ] Security implications considered

**Review Timeline**:
- Initial review within 48 hours
- Follow-up reviews within 24 hours
- Final approval from maintainers

## 🧪 Testing Guidelines

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test categories
bundle exec rspec spec/models/          # Model tests
bundle exec rspec spec/controllers/     # Controller tests
bundle exec rspec spec/requests/        # Request tests
bundle exec rspec spec/integration/     # Integration tests

# Run tests with coverage
COVERAGE=true bundle exec rspec

# Run tests in parallel (if available)
bundle exec parallel_rspec spec/
```

### Writing Tests

**Test Structure**:
```ruby
RSpec.describe TdxFeedbackGem::Feature do
  describe '#method_name' do
    context 'when condition is met' do
      it 'performs expected behavior' do
        # Arrange
        feature = described_class.new

        # Act
        result = feature.method_name

        # Assert
        expect(result).to eq(expected_value)
      end
    end

    context 'when condition is not met' do
      it 'handles error gracefully' do
        # Test error scenarios
      end
    end
  end
end
```

**Test Data**:
```ruby
# spec/factories/tdx_feedback_gem_feedbacks.rb
FactoryBot.define do
  factory :tdx_feedback_gem_feedback, class: 'TdxFeedbackGem::Feedback' do
    message { "Test feedback message" }
    context { "Test context information" }

    trait :with_user do
      user { create(:user) }
    end

    trait :long_message do
      message { "a" * 1000 }
    end
  end
end
```

### Test Coverage Requirements

- **Minimum coverage**: 90%
- **Critical paths**: 100% coverage
- **Edge cases**: Must be tested
- **Error scenarios**: Must be tested

## 📚 Documentation Guidelines

### Code Documentation

**Ruby Documentation**:
```ruby
# TdxFeedbackGem::Configuration
#
# Manages configuration for the TDX Feedback Gem.
# Supports configuration from multiple sources with priority resolution.
#
# @example Basic configuration
#   TdxFeedbackGem.configure do |config|
#     config.enable_ticket_creation = true
#     config.app_id = 31
#   end
#
# @since 1.0.0
class TdxFeedbackGem::Configuration
  # @return [Boolean] whether TDX ticket creation is enabled
  attr_accessor :enable_ticket_creation

  # @return [Integer] the TDX application ID
  attr_accessor :app_id
end
```

**JavaScript Documentation**:
```javascript
/**
 * TDX Feedback Controller
 *
 * Manages the feedback modal and form submission.
 * Handles opening/closing the modal and form interactions.
 *
 * @example
 * <button data-controller="tdx-feedback" data-action="click->tdx-feedback#openModal">
 *   Send Feedback
 * </button>
 */
class TdxFeedbackController extends Controller {
  /**
   * Opens the feedback modal
   * @param {Event} event - The click event
   */
  openModal(event) {
    // Implementation
  }
}
```

### README and Wiki Updates

**When to update documentation**:
- New features added
- Configuration options changed
- Breaking changes introduced
- Bug fixes that affect user experience
- New examples or use cases

**Documentation standards**:
- Clear, concise language
- Practical examples
- Code snippets that work
- Screenshots for UI changes
- Links to related documentation

## 🔒 Security Guidelines

### Security Considerations

**Never commit sensitive information**:
- API keys
- Passwords
- Database credentials
- Private URLs
- User data

**Security best practices**:
- Validate all user input
- Sanitize data before storage
- Use HTTPS for all external requests
- Implement proper authentication checks
- Follow OWASP guidelines

### Reporting Security Issues

**For security vulnerabilities**:
- **DO NOT** create a public issue
- **DO** email security@example.com
- **DO** include detailed reproduction steps
- **DO** wait for maintainer response

## 🚀 Performance Guidelines

### Performance Considerations

**Code performance**:
- Minimize database queries
- Use appropriate caching strategies
- Optimize asset loading
- Consider memory usage
- Profile critical paths

**Testing performance**:
```ruby
# spec/performance/feedback_performance_spec.rb
RSpec.describe 'Feedback Performance', type: :performance do
  it 'handles multiple concurrent submissions' do
    expect {
      threads = 10.times.map do
        Thread.new do
          post '/tdx_feedback_gem/feedbacks', params: {
            feedback: { message: "Performance test #{rand(1000)}" }
          }
        end
      end

      threads.each(&:join)
    }.to change(TdxFeedbackGem::Feedback, :count).by(10)
  end
end
```

## 🔄 Release Process

### Version Management

**Semantic Versioning**:
- `MAJOR.MINOR.PATCH`
- `1.0.0` - Initial release
- `1.1.0` - New features, backward compatible
- `1.0.1` - Bug fixes, backward compatible
- `2.0.0` - Breaking changes

**Release Checklist**:
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Release notes written
- [ ] GitHub release created
- [ ] RubyGems release published

### Changelog Format

```markdown
# Changelog

## [1.1.0] - 2024-01-15

### Added
- New configuration option for custom modal titles
- Support for multiple feedback types
- Enhanced error handling for TDX API failures

### Changed
- Improved performance for high-traffic applications
- Updated minimum Rails version to 5.2

### Fixed
- Modal not opening on mobile devices
- CSRF token validation issues
- Database connection timeout errors

### Removed
- Deprecated `legacy_mode` configuration option
```

## 🤝 Community Guidelines

### Code of Conduct

**Be respectful and inclusive**:
- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

**Unacceptable behavior**:
- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information
- Other conduct inappropriate for a professional environment

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community help
- **Pull Requests**: Code contributions
- **Email**: Security issues and private matters

## 🎯 Getting Help

### When You're Stuck

1. **Check existing documentation**
2. **Search existing issues**
3. **Ask in GitHub Discussions**
4. **Create a detailed issue**

### Issue Template

```markdown
## Problem Description
Clear description of what you're trying to accomplish and what's not working.

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Environment
- Ruby version: [e.g., 3.1.2]
- Rails version: [e.g., 7.0.0]
- Gem version: [e.g., 1.0.0]
- Operating system: [e.g., macOS 12.0]

## Additional Context
Any other context, logs, or screenshots that might help.
```

## 🔄 Next Steps

Now that you understand the contribution process:

1. **Set up your development environment**
2. **Find an issue to work on**
3. **Create a feature branch**
4. **Make your changes**
5. **Submit a pull request**

## 🆘 Need Help?

- Check the [Getting Started](Getting-Started.md) guide
- Review [Testing Guide](Testing) for test setup
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub
- Join [GitHub Discussions](https://github.com/lsa-mis/tdx-feedback_gem/discussions)

---

*Thank you for contributing to the TDX Feedback Gem! Your contributions help make this project better for everyone.*
