# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer
class BookingMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer/booking_status_email
  def booking_status_email
    BookingMailer.booking_status_email
  end
end
