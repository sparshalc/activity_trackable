class CompanyUser < ApplicationRecord
  include Trackable

  belongs_to :user
  belongs_to :company
  belongs_to :current_role, class_name: "Role", optional: true
  has_many :company_user_roles, dependent: :destroy
  has_many :roles, through: :company_user_roles

  validates :user_id, uniqueness: { scope: :company_id, message: "is already in this company" }
  validates :joined_at, presence: true
  validate :current_role_must_be_assigned, if: :current_role_id_changed?

  before_validation :set_joined_at, on: :create
  after_create :track_user_joined, :ensure_current_role_assignment
  after_destroy :track_user_left

  def assign_role(role)
    return false if roles.include?(role)

    company_user_roles.create!(role: role)
    update!(current_role: role) if current_role.nil?
    true
  end

  def remove_role(role)
    return false unless roles.include?(role)

    if current_role == role
      new_current_role = roles.where.not(id: role.id).first
      update!(current_role: new_current_role)
    end

    company_user_roles.find_by(role: role)&.destroy
  end

  def switch_role(role)
    return false unless roles.include?(role)
    return true if current_role == role

    old_role = current_role
    update!(current_role: role)
    track_role_switch(old_role, role)
    true
  end

  def can?(resource, action)
    current_role&.can?(resource, action) || false
  end

  def role_names
    roles.pluck(:name)
  end

  private

  def ensure_current_role_assignment
    if current_role && !roles.include?(current_role)
      company_user_roles.create!(role: current_role)
    end
  end

  def set_joined_at
    self.joined_at ||= Time.current
  end

  def current_role_must_be_assigned
    return if current_role_id.blank?
    return if company_user_roles.any? { |cur| cur.role_id == current_role_id }

    unless role_ids.include?(current_role_id)
      errors.add(:current_role, "must be one of the user's assigned roles")
    end
  end

  def track_user_joined
    track_activity("company_joined", metadata: {
      company_id: company_id,
      company_name: company.name,
      initial_role: current_role&.name
    })
  end

  def track_user_left
    track_activity("company_left", metadata: {
      company_id: company_id,
      company_name: company.name,
      roles: role_names,
      duration_days: (Time.current - joined_at).to_i / 1.day
    })
  end

  def track_role_switch(old_role, new_role)
    track_activity("role_switch", metadata: {
      company_id: company_id,
      old_role: old_role&.name,
      new_role: new_role.name
    })
  end
end
