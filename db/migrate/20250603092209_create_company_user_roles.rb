class CreateCompanyUserRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :company_user_roles do |t|
      t.references :company_user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
  end
end
