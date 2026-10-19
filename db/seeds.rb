# frozen_string_literal: true
#
# Seed data for the intentionally vulnerable HuckMe Shop lab.
# Run with: bin/rails db:seed (or docker compose exec web bin/rails db:seed)

puts "Seeding users..."

admin = User.find_or_create_by!(email: "admin@huckme.local") do |u|
  u.username = "admin"
  u.password = "Admin1234!"
  u.password_confirmation = "Admin1234!"
  u.role = "admin"
  u.ssn = "123-45-6789"
  u.credit_card_number = "4111-1111-1111-1111"
  u.bio = "System administrator."
end

alice = User.find_or_create_by!(email: "alice@huckme.local") do |u|
  u.username = "alice"
  u.password = "password123" # VULN: weak password, intentionally guessable
  u.password_confirmation = "password123"
  u.role = "user"
  u.ssn = "987-65-4321"
  u.credit_card_number = "4000-0000-0000-0002"
  u.bio = "Loves cats."
end

bob = User.find_or_create_by!(email: "bob@huckme.local") do |u|
  u.username = "bob"
  u.password = "letmein"
  u.password_confirmation = "letmein"
  u.role = "user"
  u.ssn = "555-55-5555"
  u.credit_card_number = "4000-0000-0000-0003"
  u.bio = "Collects stamps."
end

puts "Seeding products..."

laptop = Product.find_or_create_by!(name: "Developer Laptop") do |p|
  p.description = "A solid laptop for development work."
  p.price = 150_000
  p.internal_notes = "Cost basis: ¥90,000. Supplier: Acme Hardware Co. Margin target 40%."
end

keyboard = Product.find_or_create_by!(name: "Mechanical Keyboard") do |p|
  p.description = "Clicky and loud."
  p.price = 12_000
  p.internal_notes = "Supplier contact: supplier-support@acme-hardware.example / contract #HK-2291"
end

monitor = Product.find_or_create_by!(name: "4K Monitor") do |p|
  p.description = "27 inch, great colors."
  p.price = 45_000
  p.internal_notes = "Known defect batch: serials starting 2026-03 have backlight issues."
end

puts "Seeding comments..."

Comment.find_or_create_by!(user: alice, product: laptop, body: "Great laptop, fast shipping!")
Comment.find_or_create_by!(user: bob, product: laptop, body: "Battery life could be better.")
Comment.find_or_create_by!(user: alice, product: keyboard, body: "So satisfying to type on.")

puts "Seeding invoices (including cross-user IDOR targets)..."

Invoice.find_or_create_by!(user: admin, title: "Company AWS bill") { |i| i.amount = 48_230; i.status = "paid" }
Invoice.find_or_create_by!(user: alice, title: "Developer Laptop purchase") { |i| i.amount = 150_000; i.status = "paid" }
Invoice.find_or_create_by!(user: alice, title: "Mechanical Keyboard purchase") { |i| i.amount = 12_000; i.status = "unpaid" }
Invoice.find_or_create_by!(user: bob, title: "4K Monitor purchase") { |i| i.amount = 45_000; i.status = "paid" }

puts "Seeding documents + sample uploaded files..."

uploads_dir = Rails.root.join("storage", "uploads")
FileUtils.mkdir_p(uploads_dir)

File.write(uploads_dir.join("alice_resume.txt"), "Alice Doe\nSoftware Engineer\n555-0100\n")
File.write(uploads_dir.join("bob_notes.txt"), "Bob's private notes:\nWiFi password is Sunshine2026!\n")
File.write(uploads_dir.join("company_secrets.txt"), <<~TXT)
  INTERNAL ONLY - do not share.
  Payroll export passphrase: Orange-Giraffe-42
  Next product launch date: 2026-12-01
TXT

Document.find_or_create_by!(user: alice, filename: "alice_resume.txt")
Document.find_or_create_by!(user: bob, filename: "bob_notes.txt")
# Note: company_secrets.txt is intentionally NOT linked from any Document row -
# it's only reachable via the path-traversal/IDOR bug in DocumentsController#download,
# i.e. GET /documents/download?filename=company_secrets.txt as any logged-in user.

puts "Done. Seeded #{User.count} users, #{Product.count} products, " \
     "#{Comment.count} comments, #{Invoice.count} invoices, #{Document.count} documents."

puts <<~BANNER

  ==================================================
  HuckMe Shop (vulnerable lab) seeded successfully.
  Login as:
    admin@huckme.local / Admin1234!
    alice@huckme.local / password123
    bob@huckme.local   / letmein
  See VULNERABILITIES.md for the full list of bugs.
  ==================================================
BANNER
