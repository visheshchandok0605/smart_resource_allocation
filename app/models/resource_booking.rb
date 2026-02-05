# ResourceBooking is the core of our system. It tracks who wants what, when, and if it's allowed.
class ResourceBooking < ApplicationRecord
  # belongs_to links this booking to exactly one User and one OfficeResource.
  # It expects a 'user_id' and 'office_resource_id' column in the database.
  belongs_to :user
  belongs_to :office_resource

  # status tracks the lifecycle of the request.
  # 'released' is for when a user doesn't show up within 15 mins.
  enum :status, { pending: 0, approved: 1, modified: 2, rejected: 3, released: 4 }, default: :pending

  # Validation: We can't book anything without a start time, end time, or status.
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true

  # Custom validations: These are methods (defined below) that check our specific business rules.
  validate :within_office_hours
  validate :not_on_weekend
  validate :hourly_slots
  # RULE: Check for overlaps immediately, so users don't request busy slots.
  validate :no_overlap

  private

  # RULE: Maintain hourly difference in time-slot (e.g., 9:00, 10:00, not 9:15).
  def hourly_slots
    return unless start_time && end_time

    if start_time.min != 0 || end_time.min != 0
      errors.add(:base, "Bookings must start and end on the hour (e.g., 10:00, 11:00)")
    end

    if (end_time - start_time) < 1.hour
      errors.add(:base, "Minimum booking duration is 1 hour")
    end
  end

  # RULE: Office is only open 9 AM to 5 PM (17:00).
  def within_office_hours
    # Safety check: if times are missing, standard validations will catch it, so we skip here.
    return unless start_time && end_time

    # .hour returns the hour (0-23). We check if it's before 9 or after 5 PM.
    if start_time.hour < 9 || end_time.hour > 17 || (end_time.hour == 17 && end_time.min > 0)
      # errors.add(:base, ...) adds a global error message that prevents the record from saving.
      errors.add(:base, "Booking must be between 9 AM and 5 PM")
    end
    # WHY THIS APPROACH: Keeps the logic inside the model so it works everywhere (API, Console, Tests).
    # ALTERNATIVE: Check this in the Controller, but then you might forget it in other places.
  end

  # RULE: No work on weekends!
  def not_on_weekend
    return unless start_time

    # .saturday? and .sunday? are helper methods provided by Ruby's Date/Time classes.
    if start_time.saturday? || start_time.sunday?
      errors.add(:base, "Bookings are not allowed on weekends")
    end
  end

  # RULE: No double-booking!
  def no_overlap
    # We look for ANY other booking that:
    # 1. Is for the SAME resource.
    # 2. Is NOT this exact booking (using .where.not(id: id)).
    # 3. Has already been 'approved' or 'modified'.
    overlapping = ResourceBooking
      .where(office_resource_id: office_resource_id)
      #current booking is not overlapping
      .where.not(id: id)
      .where(status: [:approved, :modified])
      # This SQL checks if the requested range collides with any existing range.
      .where("(start_time, end_time) OVERLAPS (?, ?)", start_time, end_time)

    # .exists? is a fast DB query that returns true if even one record is found.
    if overlapping.exists?
      errors.add(:base, "This resource is already booked for the selected time slot")
    end
  end
end
