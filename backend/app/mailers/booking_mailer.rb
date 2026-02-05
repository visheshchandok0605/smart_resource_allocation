class BookingMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.booking_mailer.booking_status_email.subject
  #
  def booking_status_email(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.office_resource
    @greeting = "Hi #{@user.name}"

    mail(
      to: @user.email,
      subject: "Booking Update: Your request for #{@resource.name} is #{@booking.status}"
    )
  end

  def reminder_email(booking)
    @booking = booking
    @user = booking.user
    @resource = booking.office_resource
    
    mail(
      to: @user.email,
      subject: "Action Required: Your booking for #{@resource.name} starts NOW"
    )
  end
end
