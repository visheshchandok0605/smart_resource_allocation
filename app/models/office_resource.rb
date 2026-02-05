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

  # This is a "Class Method" (def self.something). You call it like OfficeResource.suggest_alternatives.
  # Its job is to find other available resources if a user's first choice is rejected.
  def self.suggest_alternatives(resource_type, start_time, end_time)
    # 1. Filter by the same resource_type and ensure it's active.
    where(resource_type: resource_type, status: :active)
      # 2. Exclude resources that ALREADY have an overlapping booking during that time.
      .where.not(id: ResourceBooking.where(status: [:approved, :modified, :pending])
                                    # OVERLAPS is a Postgres SQL command that checks if two time ranges hit each other.
                                    .where("(start_time, end_time) OVERLAPS (?, ?)", start_time, end_time)
                                    # We only care about the IDs of these busy resources.
                                    .select(:office_resource_id))
    # WHY THIS APPROACH: It uses the database (SQL) to do the heavy lifting, making it very fast.
    # ALTERNATIVE: Fetch all resources into memory and check them one-by-one with Ruby (much slower).
  end
end
