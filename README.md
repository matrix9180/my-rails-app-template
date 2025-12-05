# Rails Starter App Template

A comprehensive Rails 8.1 starter template with authentication, user profiles, and all the essential features configured the way I want them. This is my go-to template for starting new Rails projects.

**GitHub:** [matrix9180/my-rails-app-template](https://github.com/matrix9180/my-rails-app-template)

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
- **Username System** - Unique usernames (letters, numbers, dashes, underscores) with case-insensitive validation
- **Email Management** - Change email with verification requirement

### Settings Pages

The application includes a comprehensive settings system accessible at `/settings` with the following pages:

#### Profile Settings (`/settings/profile`)
- **Avatar Management** - Upload and update profile picture with image preview
- **Bio Editing** - Rich text bio editor using Action Text
- **Sudo Protection** - Requires re-authentication (sudo mode) to access

#### Password Settings (`/settings/password`)
- **Password Change** - Update password with confirmation
- **Security Validation** - Enforces minimum 12 characters
- **Pwned Check** - Validates against Have I Been Pwned database
- **Session Invalidation** - Automatically logs out all other sessions after password change
- **Sudo Protection** - Requires re-authentication (sudo mode) to access

#### Email Settings (`/settings/email`)
- **Email Change** - Update email address
- **Verification Required** - Automatically sends verification email after change
- **Email Unverification** - Email verification status reset when email changes
- **Sudo Protection** - Requires re-authentication (sudo mode) to access

#### Appearance Settings (`/settings/appearance`)
- **Theme Selection** - Choose from 35+ DaisyUI themes including:
  - Light, Dark, Cupcake, Bumblebee, Emerald, Corporate
  - Synthwave, Retro, Cyberpunk, Valentine, Halloween
  - Garden, Forest, Aqua, Lofi, Pastel, Fantasy
  - Wireframe, Black, Luxury, Dracula, CMYK
  - Autumn, Business, Acid, Lemonade, Night
  - Coffee, Winter, Dim, Nord, Sunset
  - Caramel Latte, Abyss, Silk
- **Live Preview** - Visual theme picker with color swatches
- **Instant Updates** - Theme changes apply immediately via Stimulus controller with async backend sync
- **No Sudo Required** - Accessible without re-authentication

#### Two-Factor Authentication (`/settings/two_factor_authentication`)
- **TOTP Setup** - QR code generation for authenticator apps
- **Step-by-Step Guide** - Clear instructions for setting up 2FA
- **Code Verification** - Verify TOTP code before activation
- **2FA Status** - Visual indicator when 2FA is enabled
- **Replace Setup** - Regenerate TOTP secret to replace existing setup
- **Recovery Codes** - View and regenerate recovery codes (10 codes per set)
  - Accessible at `/settings/two_factor_authentication/recovery_codes`
  - One-time use codes for account recovery
  - Regeneration invalidates previous codes

#### Session Management (`/settings/sessions`)
- **Active Sessions List** - View all active sessions across devices
- **Session Details** - Shows user agent, IP address, and creation date
- **Session Revocation** - Log out individual sessions remotely
- **Current Session** - Identifies which session you're currently using

#### Activity Log (`/settings/events`)
- **Event History** - Complete log of authentication and security events
- **Event Types** - Tracks sign in, sign out, password changes, email verification, etc.
- **Event Details** - Shows action, user agent, IP address, and timestamp
- **Chronological Order** - Events sorted by most recent first

### Admin Panel

The application includes a comprehensive admin panel for user management, accessible at `/admin` (admin-only access).

#### User Management (`/admin/users`)
- **User List** - Paginated table of all users with key information
- **Search Functionality** - Search users by username or email (case-insensitive)
- **Role Filtering** - Filter users by role (user/admin)
- **User Details** - View comprehensive user information including:
  - Username, email, role, and verification status
  - Account creation and update timestamps
  - Active sessions count (with link to view sessions)
  - Total events count (with link to view events)
  - Recovery codes count
  - Avatar display (with link to view avatar)
- **User Editing** - Edit user attributes:
  - Email address
  - Username
  - Role (admin/user) - *Note: Admins cannot change their own role*
  - Email verification status
- **User Deletion** - Delete users with confirmation dialog
  - *Note: Admins cannot delete themselves*
- **Pagination** - 25 users per page with navigation controls
- **Sidebar Navigation** - Admin panel uses the same sidebar layout as settings for consistency

#### User Events (`/admin/users/:username/events`)
- **Event History** - Paginated list of all events for a specific user
- **Event Details** - Shows action, user agent, IP address, and timestamp
- **Chronological Order** - Events sorted by most recent first (created_at desc)
- **Pagination** - 25 events per page with navigation controls
- **Event Types** - Tracks sign in, sign out, password changes, email verification, etc.
- **Read-Only** - Events are logged automatically and cannot be edited or deleted

#### User Sessions (`/admin/users/:username/sessions`)
- **Active Sessions List** - View all active sessions for a specific user
- **Session Details** - Shows user agent, IP address, creation date, and sudo status
- **Individual Sign Out** - Sign out individual user sessions remotely
- **Sign Out All** - Sign out all sessions for a user at once
- **Session Revocation** - Automatically creates "signed_out" events when sessions are destroyed
- **Sudo Indicator** - Visual badge showing which sessions have active sudo mode

#### User Avatars (`/admin/users/:username/avatar`)
- **Avatar View** - View user's avatar in full size with details
- **Avatar Information** - Displays filename, content type, file size, and upload date
- **Full Size Preview** - Link to view avatar at full resolution
- **Avatar Deletion** - Delete user's avatar with confirmation dialog
- **No Avatar Handling** - Graceful handling when user has no avatar

#### Admin Authorization
- **Role-Based Access** - Only users with `admin` role can access admin panel
- **Automatic Redirects** - Non-admin users are redirected to home page with alert message
- **Header Navigation** - Admin link appears in user dropdown menu (visible only to admins)

#### Admin Routes
- `/admin` - Admin dashboard (redirects to users index)
- `/admin/users` - User management index
- `/admin/users/:username` - View user details
- `/admin/users/:username/edit` - Edit user
- `PATCH /admin/users/:username` - Update user
- `DELETE /admin/users/:username` - Delete user
- `/admin/users/:username/events` - View user's events (paginated)
- `/admin/users/:username/sessions` - View and manage user's sessions
- `DELETE /admin/users/:username/sessions/:id` - Sign out individual session
- `DELETE /admin/users/:username/sessions/destroy_all` - Sign out all sessions
- `/admin/users/:username/avatar` - View user's avatar
- `DELETE /admin/users/:username/avatar` - Delete user's avatar

### UI & Frontend

- **Tailwind CSS 4** - Utility-first CSS framework via `tailwindcss-rails` gem (no Node.js required)
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
- SQLite3

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/matrix9180/my-rails-app-template.git
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

   **Note:** Use `bin/dev` to ensure Tailwind CSS stylesheets are generated. Using `bin/rails server` directly will not generate stylesheets.

### Development Seeds

The seed file creates sample users for development:

- `admin@example.com` (username: `admin`, password: `password123456`) - Admin user with avatar
- `user@example.com` (username: `user`, password: `password123456`) - Regular user with avatar
- `unverified@example.com` (username: `unverified`, password: `password123456`) - Unverified user

**Note:** The admin user can access the admin panel at `/admin` to manage all users.

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

#### Authentication Routes
- `/sign_in`, `/sign_up` - Sign in and registration
- `/sessions` - View active sessions
- `/sessions/passwordless` - Passwordless sign-in
- `/sessions/sudo` - Sudo mode re-authentication
- `/auth/:provider/callback` - OAuth callbacks

#### Profile Routes
- `/profile` - User's own profile
- `/profile/edit` - Edit profile (requires sudo)
- `/profiles/:username` - Public user profiles

#### Identity Routes
- `/identity/email/edit` - Change email
- `/identity/email_verification` - Email verification
- `/identity/password_reset` - Password reset

#### Two-Factor Authentication Routes
- `/two_factor_authentication/profile/totp` - 2FA setup and management
- `/two_factor_authentication/challenge/totp` - 2FA challenge during sign-in
- `/two_factor_authentication/challenge/recovery_codes` - Recovery code challenge

#### Settings Routes
- `/settings` - Settings index (redirects to profile settings)
- `/settings/profile` - Profile settings (avatar, bio)
- `/settings/password` - Password change
- `/settings/email` - Email change
- `/settings/appearance` - Theme selection
- `/settings/two_factor_authentication` - 2FA management
- `/settings/two_factor_authentication/recovery_codes` - Recovery codes
- `/settings/sessions` - Session management
- `/settings/events` - Activity log

#### Admin Routes
- `/admin` - Admin dashboard (redirects to users index)
- `/admin/users` - User management (list, search, filter)
- `/admin/users/:username` - View user details
- `/admin/users/:username/edit` - Edit user
- `/admin/users/:username/events` - View user's events (paginated, read-only)
- `/admin/users/:username/sessions` - View and manage user's sessions
- `/admin/users/:username/avatar` - View user's avatar details

#### Other Routes
- `/authentications/events` - Activity log (alternative route)

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
- 2FA support (TOTP) with OTP secret generation
- Email verification status
- Theme preference (35+ DaisyUI themes)
- Role system (user, admin, and extensible for app-specific roles)
- OAuth provider and UID for third-party authentication
- Automatic OTP secret generation on user creation
- Token generation for email verification and password reset
- Event logging for security-related actions

## Deployment

This app is configured for deployment with Kamal. See `config/deploy.yml` for deployment configuration.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Chad Ingram

## Notes

- Authentication code was generated using `authentication-zero` and has been customized for this template
- The app uses modern Rails conventions (Rails 8.1)
- Stimulus controllers replace inline JavaScript
- Flash messages are dismissible and positioned to not shift layout
- Navbar is fixed and floating
- All specs should pass before using this as a template
