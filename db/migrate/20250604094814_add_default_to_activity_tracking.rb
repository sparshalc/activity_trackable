class AddDefaultToActivityTracking < ActiveRecord::Migration[8.0]
  def change
    change_column_default :company_settings, :activity_tracking, from: nil, to: true
  end
end
