# Rails Starter App Template

A comprehensive Rails 8.1 starter template with authentication, user profiles, and all the essential features configured the way I want them. This is my go-to template for starting new Rails projects.

## Features

### Authentication & Security

- **Email/Password Authentication** - Secure password-based authentication with bcrypt
- **OAuth Support** - Multi-provider authentication via OmniAuth (ready for GitHub, Google, etc.)
- **Two-Factor Authentication (2FA)** - TOTP-based 2FA with QR code generation and recovery codes
- **Passwordless Sign-In** - Magic link authentication via email
- **Sudo Mode** - Re-authentication required for sensitive actions (30-minute window)
- **Password Security** - Minimum 12 characters, checked against Have I Been Pwned database
- **Email Verification** - Email verification system with token-based verification
- **Password Reset** - Secure password reset flow with expiring tokens
- **Session Management** - Multiple device sessions with ability to view and revoke sessions
- **Activity Logging** - Authentication events tracking (sign in, sign out, password changes, etc.)

### User Profiles

- **User Profiles** - Public user profiles with username-based URLs
- **User Avatars** - Profile picture uploads via Active Storage
- **Rich Text Bios** - Action Text integration for rich text user bios
- **Username System** - Unique, alphanumeric usernames with case-insensitive validation
- **Email Management** - Change email with verification requirement

### UI & Frontend

- **Tailwind CSS** - Utility-first CSS framework
- **DaisyUI** - Beautiful component library built on Tailwind
- **Hotwire (Turbo + Stimulus)** - Modern, lightweight JavaScript framework
- **Responsive Design** - Mobile-first responsive layout
- **Fixed Navigation** - Floating navbar that stays at the top
- **Flash Messages** - Dismissible flash messages with type-based styling (success, error, warning, info)
- **Modern UI Components** - Dropdown menus, alerts, buttons, and more

### Development & Testing

- **RSpec** - Comprehensive test suite with RSpec
- **Factory Bot** - Test data factories
- **Shoulda Matchers** - Simplified model and controller tests
- **Brakeman** - Security vulnerability scanner
- **Bundler Audit** - Dependency security auditing
- **RuboCop** - Code style enforcement (Omakase configuration)
- **Annotate** - Automatic model annotations

### Infrastructure

- **Rails 8.1** - Latest Rails framework
- **SQLite3** - Database (easily switchable to PostgreSQL)
- **Solid Queue** - Database-backed job queue
- **Solid Cache** - Database-backed cache store
- **Solid Cable** - Database-backed Action Cable adapter
- **Kamal** - Docker-based deployment
- **Puma** - High-performance web server
- **Thruster** - HTTP asset caching and compression

### Additional Features

- **Action Text** - Rich text editing and storage
- **Active Storage** - File uploads and attachments
- **Import Maps** - Modern JavaScript without a build step
- **PWA Ready** - Progressive Web App support (manifest and service worker ready)
- **Syntax Highlighting** - Code syntax highlighting with Lexxy

## Getting Started

### Prerequisites

- Ruby 3.3+ (check `.ruby-version`)
- Node.js and npm (for Tailwind CSS)
- SQLite3

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd my-rails-app-template
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

4. Start the development server:
   ```bash
   bin/dev
   ```

   Or use the traditional approach:
   ```bash
   bin/rails server
   ```

### Development Seeds

The seed file creates sample users for development:

- `admin@example.com` (username: `admin`, password: `password123456`) - with avatar
- `user@example.com` (username: `user`, password: `password123456`) - with avatar
- `unverified@example.com` (username: `unverified`, password: `password123456`) - unverified

### Running Tests

```bash
bundle exec rspec
```

### Code Quality

Run security audits:
```bash
bin/brakeman
bin/bundler-audit
```

Run linter:
```bash
bin/rubocop
```

## Project Structure

### Key Directories

- `app/controllers/` - Application controllers including authentication controllers
- `app/models/` - User, Session, Event, RecoveryCode, SignInToken models
- `app/views/application/` - Shared partials (header, footer, flash)
- `app/javascript/controllers/` - Stimulus controllers
- `spec/` - RSpec test suite
- `config/initializers/` - OmniAuth and other configurations

### Authentication Flow

1. **Registration** - Users sign up with email, username, and password
2. **Email Verification** - Users receive verification email (optional, based on configuration)
3. **Sign In** - Standard email/password or OAuth
4. **2FA Challenge** - If 2FA is enabled, users must provide TOTP code
5. **Session Management** - Users can view and manage active sessions
6. **Sudo Mode** - Sensitive actions require re-authentication

### Routes

Key routes include:
- `/sign_in`, `/sign_up` - Authentication
- `/profile` - User's own profile
- `/profile/edit` - Edit profile (requires sudo)
- `/sessions` - View active sessions
- `/identity/email/edit` - Change email
- `/identity/password_reset` - Password reset
- `/two_factor_authentication/profile/totp` - 2FA setup
- `/authentications/events` - Activity log

## Configuration

### OAuth Providers

Configure OAuth providers in `config/initializers/omniauth.rb`. Example:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_KEY"], ENV["GITHUB_SECRET"]
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end
```

### Email Configuration

Configure email delivery in `config/environments/` files. The app uses Action Mailer for:
- Email verification
- Password reset
- Passwordless sign-in links

### Database

By default, the app uses SQLite3. To switch to PostgreSQL:

1. Update `Gemfile` to use `pg` instead of `sqlite3`
2. Update `config/database.yml`
3. Run `bundle install` and `bin/rails db:create db:migrate`

## Customization

### Styling

- Tailwind configuration: `app/assets/tailwind/`
- DaisyUI theme: `app/assets/tailwind/daisyui-theme.mjs`
- Custom styles: `app/assets/stylesheets/`

### Flash Messages

Flash messages are handled via a Stimulus controller (`app/javascript/controllers/flash_controller.js`) and helper methods in `ApplicationHelper`:
- `flash_alert_class(type)` - Returns CSS class for flash type
- `flash_icon_path(type)` - Returns SVG path for flash icon

### User Model

The `User` model includes:
- Email and username (both unique, case-insensitive)
- Password with secure hashing
- Avatar attachment (Active Storage)
- Rich text bio (Action Text)
- 2FA support (TOTP)
- Email verification status

## Deployment

This app is configured for deployment with Kamal. See `config/deploy.yml` for deployment configuration.

## License

This is a personal starter template. Use it as you wish.

## Notes

- Authentication code was generated using `authentication-zero` and has been customized for this template
- The app uses modern Rails conventions (Rails 8.1)
- Stimulus controllers replace inline JavaScript
- Flash messages are dismissible and positioned to not shift layout
- Navbar is fixed and floating
- All specs should pass before using this as a template
