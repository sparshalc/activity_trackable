class CreateCompanySettings < ActiveRecord::Migration[8.0]
  def change
    create_table :company_settings do |t|
      t.references :company, null: false, foreign_key: true
      t.boolean :activity_tracking
      t.integer :activity_retention_days

      t.timestamps
    end
  end
end
