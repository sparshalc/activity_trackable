class CompanySetting < ApplicationRecord
  belongs_to :company

  validates :activity_retention_days, numericality: { greater_than_or_equal_to: 1 }
end
