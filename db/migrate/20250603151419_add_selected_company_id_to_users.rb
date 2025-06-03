class AddSelectedCompanyIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :selected_company_id, :integer
  end
end
