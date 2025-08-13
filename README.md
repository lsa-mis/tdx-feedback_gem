gem 'tdx_feedback_gem', path: 'path/to/tdx_feedback_gem'
bundle install

# tdx_feedback_gem

A Ruby gem for collecting feedback, designed for easy integration with Rails applications.

## Features

- Collect and manage user feedback
- Rails-compatible
- MIT License

## Rails Usage

Mount the engine and expose a create endpoint:

```ruby
# config/routes.rb
mount TdxFeedbackGem::Engine => "/feedback"
```

Run the installer to add the migration and initializer to your app:

```sh
bin/rails g tdx_feedback_gem:install
bin/rails db:migrate
```

Submit feedback with:

POST /feedback/feedbacks with params `{ feedback: { message: "...", context: "..." } }`

Or use the built-in form at:

GET /feedback (renders a minimal form)

### Render flashes globally in a host app

Add this to your Rails app layout so success/error messages from the engine appear consistently:

```erb
<!-- app/views/layouts/application.html.erb -->
<body>
 <%= render 'tdx_feedback_gem/shared/flashes' %>
 <%= yield %>
</body>
```

Optional: include the engine CSS for minimal styling.

```css
/* app/assets/stylesheets/application.css */
/*
 *= require tdx_feedback_gem
 */
```

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'tdx_feedback_gem', path: 'path/to/tdx_feedback_gem'
```

Then execute:

```sh
bundle install
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
