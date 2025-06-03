class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :trackable, polymorphic: true, null: false
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # Who performed the action
      t.string :action, null: false
      t.jsonb :metadata, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :activities, :action
    add_index :activities, :occurred_at
    add_index :activities, [ :company_id, :occurred_at ]
    add_index :activities, [ :company_id, :action ]
    add_index :activities, [ :user_id, :occurred_at ]
    add_index :activities, :metadata
  end
end
