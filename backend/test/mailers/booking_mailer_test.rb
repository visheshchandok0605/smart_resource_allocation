require "test_helper"

class BookingMailerTest < ActionMailer::TestCase
  setup do
    @user = User.create!(name: "Test User", email: "test_#{SecureRandom.hex}@example.com", password: "password", role: :employee, employee_id: "EMP-#{SecureRandom.hex(4)}")
    @resource = OfficeResource.create!(name: "Meeting Room A", resource_type: :room)
    @booking = ResourceBooking.create!(
      user: @user, 
      office_resource: @resource, 
      start_time: Time.current.beginning_of_hour + 2.hours, 
      end_time: Time.current.beginning_of_hour + 3.hours,
      status: :approved
    )
  end

  test "booking_status_email" do
    # Send the email, then test that it got queued
    email = BookingMailer.booking_status_email(@booking)

    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect
    assert_equal [@user.email], email.to
    assert_match(/Booking Update/, email.subject)
    assert_match(/Hello, #{@user.name}/, email.html_part.body.encoded)
    assert_match(/approved/, email.html_part.body.encoded)
  end

  test "reminder_email" do
    email = BookingMailer.reminder_email(@booking)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_match(/Action Required/, email.subject)
    assert_match(/Your booking for Meeting Room A starts NOW/, email.subject)
    assert_match(/Time to Check-in/, email.html_part.body.encoded)
  end
end
