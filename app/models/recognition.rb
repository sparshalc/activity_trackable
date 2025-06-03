class Recognition < ApplicationRecord
  acts_as_tenant(:company)

  include Trackable

  belongs_to :giver, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :activities, as: :trackable, dependent: :destroy

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  CATEGORIES = [ "teamwork", "innovation", "leadership", "customer_service", "going_above_beyond" ].freeze

  validates :category, inclusion: { in: CATEGORIES }
  validates :points, presence: true, numericality: { greater_than: 0 }
  validates :message, presence: true
  validates :category, presence: true
  validate :cannot_recognize_self
  validate :users_in_same_company

  scope :recent, -> { order(created_at: :desc) }
  scope :approved, -> { where(status: :approved) }
  scope :for_recipient, ->(user_id) { where(recipient_id: user_id) }
  scope :for_giver, ->(user_id) { where(giver_id: user_id) }

  after_create :track_recognition_activities

  private

  def cannot_recognize_self
    errors.add(:recipient, "can't recognize yourself") if giver_id == recipient_id
  end

  def users_in_same_company
    unless giver.companies.exists?(id: company_id) && recipient.companies.exists?(id: company_id)
      errors.add(:base, "Users must be in the same company")
    end
  end

  def track_recognition_activities
    track_activity("give_recognition",
      user: giver,
      metadata: {
        recognition_id: id,
        recipient_user_id: recipient_id,
        recipient_name: recipient.full_name,
        points_given: points,
        category: category,
        message_preview: message.truncate(100)
      }
    )

    track_activity("receive_recognition",
      user: recipient,
      metadata: {
        recognition_id: id,
        giver_user_id: giver_id,
        giver_name: giver.full_name,
        points_received: points,
        category: category
      }
    )
  end
end
