class CompanyUserRole < ApplicationRecord
  include Trackable

  belongs_to :company_user
  belongs_to :role

  validates :role_id, uniqueness: { scope: :company_user_id, message: "has already been assigned" }

  after_create :track_role_assignment
  after_destroy :track_role_removal

  private

  def track_role_assignment
    track_activity("role_assigned",
      user: company_user.user,
      metadata: {
        company_id: company_user.company_id,
        role_name: role.name,
        assigned_at: created_at
      }
    )
  end

  def track_role_removal
    track_activity("role_removed",
      user: company_user.user,
      metadata: {
        company_id: company_user.company_id,
        role_name: role.name,
        removed_at: Time.current
      }
    )
  end
end
