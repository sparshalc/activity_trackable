class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.text :description
      t.jsonb :permissions
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
