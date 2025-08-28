Complete examples for integrating the TDX Feedback Gem with different Rails versions, authentication systems, and deployment platforms.

## 🚀 Rails Version Integration

### Rails 7 with Import Maps

#### Import Map Configuration

```ruby
# config/importmap.rb
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "tdx_feedback_gem", to: "tdx_feedback_gem.js"
```

#### Application JavaScript

```javascript
// app/javascript/application.js
import "@hotwired/stimulus-loading"
import "tdx_feedback_gem"
```

#### Layout Integration

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Your App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbo-track': 'reload' %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
    <header>
      <%= feedback_header_button %>
    </header>

    <main>
      <%= yield %>
    </main>

    <footer>
      <%= feedback_footer_link %>
    </footer>
  </body>
</html>
```

### Rails 6 with Webpacker

#### Webpacker Configuration

```javascript
// app/javascript/packs/application.js
import '@hotwired/stimulus'
import 'tdx_feedback_gem'
```

#### Package Configuration

```json
// package.json
{
  "dependencies": {
    "@hotwired/stimulus": "^3.0.0",
    "tdx_feedback_gem": "file:vendor/gems/tdx_feedback_gem"
  }
}
```

#### Layout Integration

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Your App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <header>
      <%= feedback_header_button %>
    </header>

    <main>
      <%= yield %>
    </main>

    <footer>
      <%= feedback_footer_link %>
    </footer>
  </body>
</html>
```

### Rails 5 with Asset Pipeline

#### Asset Pipeline Configuration

```ruby
# app/assets/javascripts/application.js
//= require jquery
//= require jquery_ujs
//= require tdx_feedback_gem
```

```ruby
# app/assets/stylesheets/application.css
/*
 *= require_self
 *= require tdx_feedback_gem
 *= require_tree .
 */
```

#### Layout Integration

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Your App</title>
    <%= csrf_meta_tags %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <header>
      <%= feedback_header_button %>
    </header>

    <main>
      <%= yield %>
    </main>

    <footer>
      <%= feedback_footer_link %>
    </footer>
  </body>
</html>
```

## 🔐 Authentication System Integration

### Devise Authentication

#### Application Controller

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Devise provides current_user method automatically
  # No additional configuration needed
end
```

#### Configuration

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.require_authentication = true

  # TDX configuration...
  config.enable_ticket_creation = true
  config.app_id = 31
  config.type_id = 12
  config.status_id = 77
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631
end
```

#### User Model Integration

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Optional: Add feedback association
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback'
end
```

#### View Integration

```erb
<!-- app/views/layouts/application.html.erb -->
<% if user_signed_in? %>
  <header>
    <nav>
      <span>Welcome, <%= current_user.email %></span>
      <%= feedback_header_button %>
      <%= link_to 'Sign Out', destroy_user_session_path, method: :delete %>
    </nav>
  </header>
<% else %>
  <header>
    <nav>
      <%= link_to 'Sign In', new_user_session_path %>
      <%= link_to 'Sign Up', new_user_registration_path %>
    </nav>
  </header>
<% end %>
```

### Custom Authentication

#### Application Controller

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    unless current_user
      redirect_to login_path, alert: 'Please log in to continue'
    end
  end
end
```

#### User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # Optional: Add feedback association
  has_many :feedbacks, class_name: 'TdxFeedbackGem::Feedback'

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

#### Session Controller

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Logged in successfully'
    else
      flash.now[:alert] = 'Invalid email or password'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Logged out successfully'
  end
end
```

#### Configuration

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.require_authentication = true

  # TDX configuration...
  config.enable_ticket_creation = true
  config.app_id = 31
  config.type_id = 12
  config.status_id = 77
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631
end
```

### No Authentication

#### Configuration

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.require_authentication = false

  # TDX configuration...
  config.enable_ticket_creation = true
  config.app_id = 31
  config.type_id = 12
  config.status_id = 77
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631
end
```

#### Layout Integration

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Your App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <header>
      <%= feedback_header_button %>
    </header>

    <main>
      <%= yield %>
    </main>

    <footer>
      <%= feedback_footer_link %>
    </footer>
  </body>
</html>
```

## 🚀 Deployment Platform Integration

### Docker Deployment

#### Dockerfile

```dockerfile
# Dockerfile
FROM ruby:3.1-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
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

# Expose port
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

#### Docker Compose

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
      - TDX_ENABLE_TICKET_CREATION=true
      - TDX_CLIENT_ID=${TDX_CLIENT_ID}
      - TDX_CLIENT_SECRET=${TDX_CLIENT_SECRET}
      - TDX_BASE_URL=${TDX_BASE_URL}
      - TDX_OAUTH_TOKEN_URL=${TDX_OAUTH_TOKEN_URL}
    depends_on:
      - db
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp_production
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${DATABASE_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
  bundle_cache:
```

#### Environment File

```bash
# .env
TDX_CLIENT_ID=your_client_id_here
TDX_CLIENT_SECRET=your_client_secret_here
TDX_BASE_URL=https://gw.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw.api.it.umich.edu/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=true
DATABASE_PASSWORD=your_database_password
```

### Kubernetes Deployment

#### Deployment Configuration

```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tdx-feedback-app
  labels:
    app: tdx-feedback-app
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
      - name: tdx-feedback-app
        image: your-registry/tdx-feedback-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: RAILS_ENV
          value: "production"
        - name: TDX_ENABLE_TICKET_CREATION
          value: "true"
        - name: TDX_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: tdx-secrets
              key: client-id
        - name: TDX_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: tdx-secrets
              key: client-secret
        - name: TDX_BASE_URL
          value: "https://gw.api.it.umich.edu/um/it"
        - name: TDX_OAUTH_TOKEN_URL
          value: "https://gw.api.it.umich.edu/um/oauth2/token"
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

#### Service Configuration

```yaml
# kubernetes/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: tdx-feedback-app-service
spec:
  selector:
    app: tdx-feedback-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

#### Secrets Configuration

```yaml
# kubernetes/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: tdx-secrets
type: Opaque
data:
  client-id: <base64-encoded-client-id>
  client-secret: <base64-encoded-client-secret>
```

#### Ingress Configuration

```yaml
# kubernetes/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tdx-feedback-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: your-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tdx-feedback-app-service
            port:
              number: 80
```

### Heroku Deployment

#### Heroku Configuration

```bash
# Set environment variables
heroku config:set TDX_ENABLE_TICKET_CREATION=true
heroku config:set TDX_CLIENT_ID=your_client_id
heroku config:set TDX_CLIENT_SECRET=your_client_secret
heroku config:set TDX_BASE_URL=https://gw.api.it.umich.edu/um/it
heroku config:set TDX_OAUTH_TOKEN_URL=https://gw.api.it.umich.edu/um/oauth2/token
heroku config:set RAILS_ENV=production
```

#### Procfile

```procfile
# Procfile
web: bundle exec rails server -p $PORT -e $RAILS_ENV
```

#### App Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # ... other configuration ...

  # Force all access to the app over SSL, use Strict-Transport-Security
  config.force_ssl = true

  # Precompile additional assets
  config.assets.precompile += %w( tdx_feedback_gem.css tdx_feedback_gem.js )

  # Compress CSS using a preprocessor
  config.assets.css_compressor = :sass

  # Compress JavaScript
  config.assets.js_compressor = :terser
end
```

## 🎯 Advanced Integration Examples

### Multiple Feedback Forms

#### Different Feedback Types

```erb
<!-- app/views/layouts/application.html.erb -->
<header>
  <!-- General feedback -->
  <%= feedback_header_button %>

  <!-- Bug report feedback -->
  <%= feedback_system(
    trigger: :button,
    text: 'Report Bug',
    class: 'btn-danger',
    data: { feedback_type: 'bug' }
  ) %>

  <!-- Feature request feedback -->
  <%= feedback_system(
    trigger: :button,
    text: 'Request Feature',
    class: 'btn-success',
    data: { feedback_type: 'feature' }
  ) %>
</header>
```

#### Custom Feedback Context

```erb
<!-- app/views/pages/show.html.erb -->
<div class="page-content">
  <h1><%= @page.title %></h1>
  <p><%= @page.content %></p>

  <!-- Page-specific feedback -->
  <%= feedback_system(
    trigger: :button,
    text: 'Feedback on this page',
    class: 'btn-outline-primary',
    data: {
      page_id: @page.id,
      page_title: @page.title,
      feedback_context: "User was viewing page: #{@page.title}"
    }
  ) %>
</div>
```

### Conditional Feedback Display

#### User Role-Based Display

```erb
<!-- app/views/layouts/application.html.erb -->
<% if current_user&.admin? %>
  <!-- Admin feedback form -->
  <%= feedback_system(
    trigger: :button,
    text: 'Admin Feedback',
    class: 'btn-warning',
    data: { user_role: 'admin' }
  ) %>
<% elsif current_user&.moderator? %>
  <!-- Moderator feedback form -->
  <%= feedback_system(
    trigger: :button,
    text: 'Moderator Feedback',
    class: 'btn-info',
    data: { user_role: 'moderator' }
  ) %>
<% else %>
  <!-- Regular user feedback -->
  <%= feedback_header_button %>
<% end %>
```

#### Environment-Based Display

```erb
<!-- app/views/layouts/application.html.erb -->
<% if Rails.env.development? %>
  <!-- Development feedback with debug info -->
  <%= feedback_system(
    trigger: :button,
    text: 'Dev Feedback',
    class: 'btn-secondary',
    data: {
      environment: 'development',
      debug_mode: 'true'
    }
  ) %>
<% else %>
  <!-- Production feedback -->
  <%= feedback_header_button %>
<% end %>
```

## 🔄 Next Steps

Now that you have integration examples:

1. **[Styling and Theming](Styling-and-Theming)** - Customize the appearance
2. **[Advanced Customization](Advanced-Customization)** - Extend functionality
3. **[Testing Guide](Testing)** - Test your integration
4. **[Production Deployment](Production-Deployment)** - Deploy with confidence

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more advanced integration patterns, see the [Advanced Customization](Advanced-Customization) guide.*
