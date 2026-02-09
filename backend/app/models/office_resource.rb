# The OfficeResource model handles meeting rooms, laptops, phones, and turfs.
class OfficeResource < ApplicationRecord
  # We use enums for resource_type to distinguish between rooms and equipment.
  # WHY: Fast database queries and cleaner "office_resource.meeting_room?" checks in code.
  enum :resource_type, { room: 0, equipment: 1, turf: 2 }
  
  # 'status' tracks if the item is ready for use or currently being fixed (maintenance).
  enum :status, { active: 0, maintenance: 1 }, default: :active

  # Standard presence validations to ensure every resource has a name and type.
  validates :name, presence: true
  validates :resource_type, presence: true
  validates :status, presence: true

  # One resource can be booked many times (at different time slots).
  has_many :resource_bookings

  # This is a general check for what is available during a specific time.
  def self.available_during(start_time, end_time)
    where(status: :active).where.not(id: ResourceBooking.where(status: [:approved, :modified, :pending])
                                    .where("(start_time, end_time) OVERLAPS (?, ?)", start_time, end_time)
                                    .select(:office_resource_id))
  end

  # This is a "Class Method" (def self.something). You call it like OfficeResource.suggest_alternatives.
  # Its job is to find other available resources if a user's first choice is rejected.
  def self.suggest_alternatives(resource_type, start_time, end_time, exclude_id: nil)
    # 1. Start with resources of the same type
    resources = where(resource_type: resource_type)

    # 2. Exclude the original resource if specified.
    resources = resources.where.not(id: exclude_id) if exclude_id.present?

    # 3. Filter for availability using our general scope
    resources.available_during(start_time, end_time)
  end
end
