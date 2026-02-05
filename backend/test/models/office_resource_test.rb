require "test_helper"

class OfficeResourceTest < ActiveSupport::TestCase
  setup do
    @room = office_resources(:room)
    @laptop = office_resources(:laptop)
    @base_time = Time.zone.parse("2026-02-09 10:00:00")
  end

  test "suggests alternatives for a busy room" do
    # Create another room that is free
    free_room = OfficeResource.create!(name: "Conference Room B", resource_type: :room, status: :active)

    # Book the first room
    ResourceBooking.create!(
      user: users(:employee),
      office_resource: @room,
      start_time: @base_time,
      end_time: @base_time + 1.hour,
      status: :approved
    )

    # Search for alternatives room
    alternatives = OfficeResource.suggest_alternatives(:room, @base_time, @base_time + 1.hour)

    assert_includes alternatives, free_room
    assert_not_includes alternatives, @room
  end

  test "does not suggest maintenance resources" do
    m_room = office_resources(:maintenance_room)
    alternatives = OfficeResource.suggest_alternatives(:room, @base_time, @base_time + 1.hour)
    
    assert_not_includes alternatives, m_room
  end

  test "does not suggest resources with pending/modified/approved bookings" do
    # Create another room
    room_b = OfficeResource.create!(name: "Room B", resource_type: :room, status: :active)
    
    # Add a pending booking for room B
    ResourceBooking.create!(
      user: users(:employee),
      office_resource: room_b,
      start_time: @base_time,
      end_time: @base_time + 1.hour,
      status: :pending
    )

    alternatives = OfficeResource.suggest_alternatives(:room, @base_time, @base_time + 1.hour)
    assert_not_includes alternatives, room_b
  end
end
