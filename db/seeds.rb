# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample users for development
if Rails.env.development?
  admin = User.find_or_create_by!(email: "admin@example.com") do |user|
    user.username = "admin"
    user.password = "password123456"
    user.password_confirmation = "password123456"
    user.verified = true
    user.role = "admin"
  end

  # Attach avatar to admin if not already attached
  unless admin.avatar.attached?
    admin.avatar.attach(
      io: File.open(Rails.root.join("spec", "fixtures", "files", "test_image.jpg")),
      filename: "test_image.jpg",
      content_type: "image/jpeg"
    )
  end

  user1 = User.find_or_create_by!(email: "user@example.com") do |user|
    user.username = "user"
    user.password = "password123456"
    user.password_confirmation = "password123456"
    user.verified = true
  end

  # Attach avatar to user1 if not already attached
  unless user1.avatar.attached?
    user1.avatar.attach(
      io: File.open(Rails.root.join("spec", "fixtures", "files", "test_image.png")),
      filename: "test_image.png",
      content_type: "image/png"
    )
  end

  unverified_user = User.find_or_create_by!(email: "unverified@example.com") do |user|
    user.username = "unverified"
    user.password = "password123456"
    user.password_confirmation = "password123456"
    user.verified = false
  end

  puts "Created users:"
  puts "  - admin@example.com (username: admin, password: password123456) - with avatar"
  puts "  - user@example.com (username: user, password: password123456) - with avatar"
  puts "  - unverified@example.com (username: unverified, password: password123456)"
end
