class AddCurrentRoleToCompanyUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :company_users, :current_role, foreign_key: { to_table: :roles }, null: true
  end
end
