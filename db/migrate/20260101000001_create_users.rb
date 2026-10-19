class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, default: "user" # VULN: role is a plain mass-assignable string, no enum/authorization check
      t.string :api_token
      t.string :ssn # VULN: sensitive PII stored in plaintext
      t.string :credit_card_number # VULN: sensitive PII stored in plaintext, unencrypted
      t.text :bio

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :api_token, unique: true
  end
end
