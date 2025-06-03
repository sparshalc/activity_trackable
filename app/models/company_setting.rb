class CompanySetting < ApplicationRecord
  acts_as_tenant(:company)

  validates :activity_retention_days, numericality: { greater_than_or_equal_to: 1 }
end
