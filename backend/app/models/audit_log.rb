class AuditLog < ApplicationRecord
  # subject corresponds to the model being logged (e.g., OfficeResource, ResourceBooking).
  # Using polymorphic association because different types of records will be logged here.
  belongs_to :subject, polymorphic: true

  # Validations: ensuring every log entry has an event type.
  validates :event, presence: true

  # Helper method to log events quickly.
  def self.log(subject, event, details = nil)
    create(
      subject: subject,
      event: event,
      details: details
    )
  end
end
