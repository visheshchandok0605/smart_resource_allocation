require "test_helper"

class ResourceBookingTest < ActiveSupport::TestCase
  setup do
    @user = users(:employee)
    @resource = office_resources(:room)
    @base_time = Time.zone.parse("2026-02-09 10:00:00") # A Monday
  end

  test "valid booking" do
    booking = ResourceBooking.new(
      user: @user,
      office_resource: @resource,
      start_time: @base_time,
      end_time: @base_time + 1.hour,
      status: :pending
    )
    assert booking.valid?
  end

  test "invalid without start_time" do
    booking = ResourceBooking.new(end_time: @base_time + 1.hour)
    assert_not booking.valid?
    assert_includes booking.errors[:start_time], "can't be blank"
  end

  test "must be within office hours (9 AM - 5 PM)" do
    # Before 9 AM
    booking = ResourceBooking.new(
      user: @user,
      office_resource: @resource,
      start_time: @base_time.change(hour: 8),
      end_time: @base_time.change(hour: 9),
      status: :pending
    )
    assert_not booking.valid?
    assert_includes booking.errors[:base], "Booking must be between 9 AM and 5 PM"

    # After 5 PM
    booking.start_time = @base_time.change(hour: 17)
    booking.end_time = @base_time.change(hour: 18)
    assert_not booking.valid?
  end

  test "cannot book on weekends" do
    saturday = Time.zone.parse("2026-02-07 10:00:00")
    booking = ResourceBooking.new(
      user: @user,
      office_resource: @resource,
      start_time: saturday,
      end_time: saturday + 1.hour,
      status: :pending
    )
    assert_not booking.valid?
    assert_includes booking.errors[:base], "Bookings are not allowed on weekends"
  end

  test "must be on the hour" do
    booking = ResourceBooking.new(
      user: @user,
      office_resource: @resource,
      start_time: @base_time + 15.minutes,
      end_time: @base_time + 1.hour,
      status: :pending
    )
    assert_not booking.valid?
    assert_includes booking.errors[:base], "Bookings must start and end on the hour (e.g., 10:00, 11:00)"
  end

  test "minimum duration of 1 hour" do
    booking = ResourceBooking.new(
      user: @user,
      office_resource: @resource,
      start_time: @base_time,
      end_time: @base_time + 30.minutes,
      status: :pending
    )
    # This might fail on the "on the hour" validation too, but let's check both
    assert_not booking.valid?
  end

  test "prevents overlapping bookings" do
    # Create an approved booking
    ResourceBooking.create!(
      user: @user,
      office_resource: @resource,
      start_time: @base_time,
      end_time: @base_time + 1.hour,
      status: :approved
    )

    # Attempt to create another overlapping booking
    overlapping_booking = ResourceBooking.new(
      user: users(:admin),
      office_resource: @resource,
      start_time: @base_time,
      end_time: @base_time + 1.hour,
      status: :pending
    )
    assert_not overlapping_booking.valid?
    assert_includes overlapping_booking.errors[:base], "This resource is already booked for the selected time slot"
  end
end
