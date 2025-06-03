class CreateRecognitions < ActiveRecord::Migration[8.0]
  def change
    create_table :recognitions do |t|
      t.integer :giver_id, null: false
      t.integer :recipient_id, null: false
      t.references :company, null: false, foreign_key: true
      t.integer :points, null: false
      t.text :message, null: false
      t.string :category, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :recognitions, :users, column: :giver_id
    add_foreign_key :recognitions, :users, column: :recipient_id

    add_index :recognitions, :giver_id
    add_index :recognitions, :recipient_id
    add_index :recognitions, :category
    add_index :recognitions, :status
    add_index :recognitions, [ :company_id, :created_at ]
    add_index :recognitions, [ :giver_id, :created_at ]
    add_index :recognitions, [ :recipient_id, :created_at ]
  end
end
