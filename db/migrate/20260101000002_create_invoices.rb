class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, default: "unpaid"

      t.timestamps
    end
  end
end
