class User < ApplicationRecord
  has_secure_password

  has_many :invoices
  has_many :comments
  has_many :documents

  # VULN (Broken Access Control / Mass Assignment): no attr allowlist here — controllers
  # decide what to permit, and the admin controller intentionally permits :role.

  before_create :generate_api_token

  private

  def generate_api_token
    # VULN (Insecure Randomness / Predictable Token): low-entropy, time-seeded token.
    # Easy to brute force or predict, unlike SecureRandom.hex.
    self.api_token = Digest::MD5.hexdigest("#{email}-#{Time.now.to_i}")
  end
end
