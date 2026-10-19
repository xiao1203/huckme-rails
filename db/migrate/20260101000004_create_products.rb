class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :internal_notes # VULN: internal/admin-only field exposed through a public JSON endpoint

      t.timestamps
    end
  end
end
