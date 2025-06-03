module Trackable
  extend ActiveSupport::Concern

  def track_activity(action, user: nil, metadata: {})
    return unless should_track_activity?

    Activity.track(
      trackable: self,
      action: action,
      user: user || self.try(:user) || (self.is_a?(User) ? self : nil),
      metadata: metadata
    )
  end

  def track_activity!(action, user: nil, metadata: {})
    return unless should_track_activity?

    Activity.track!(
      trackable: self,
      action: action,
      user: user || self.try(:user) || (self.is_a?(User) ? self : nil),
      metadata: metadata
    )
  end

  private

  def should_track_activity?
    company = case self
    when Company
      self
    when User
      current_company
    else
      self.try(:company)
    end

    company&.activity_tracking?
  end
end
