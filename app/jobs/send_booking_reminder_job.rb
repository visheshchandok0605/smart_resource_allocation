class SendBookingReminderJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = ResourceBooking.find_by(id: booking_id)
    return unless booking && booking.approved?

    # Only send reminder if not already checked in
    return if booking.checked_in_at.present?

    BookingMailer.reminder_email(booking).deliver_now
  end
end
