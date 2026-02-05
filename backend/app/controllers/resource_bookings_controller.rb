# ResourceBookingsController manages the requests made by employees.
class ResourceBookingsController < ApplicationController
  # CanCanCan handles loading the booking and checking permissions.
  # We except the quick actions from authorization so they work directly from email links.
  load_and_authorize_resource except: [:quick_check_in, :quick_cancel]
  load_resource only: [:quick_check_in, :quick_cancel]

  skip_before_action :authenticate_user!, only: [:quick_check_in, :quick_cancel]

  # GET /resource_bookings - Shows bookings relative to the user's role.
  def index
    # @resource_bookings is automatically scoped by CanCanCan 
    # (Admins see all, Employees see only their own via Ability.rb).
    render json: @resource_bookings
  end

  # GET /resource_bookings/:id - Shows details of a specific request.
  def show
    render json: @resource_booking
  end

  # POST /resource_bookings - An employee submits a new booking request.
  def create
    @resource_booking.user = current_user
    @resource_booking.status = :pending

    if @resource_booking.save
      render json: @resource_booking, status: :created
    else
      # Prepare the error response
      response = { errors: @resource_booking.errors.full_messages }

      # If there is a conflict, we look for alternatives
      if @resource_booking.errors.added?(:base, "This resource is already booked for the selected time slot")
        alternatives = OfficeResource.suggest_alternatives(
          @resource_booking.office_resource.resource_type,
          @resource_booking.start_time,
          @resource_booking.end_time
        )
        response[:suggested_alternatives] = alternatives if alternatives.any?
      end
      
      render json: response, status: :unprocessable_entity
    end
  end

  # PATCH /resource_bookings/:id/approve - (Admin only)
  def approve
    # If the resource is a room, generate a meeting link
    if @resource_booking.office_resource.room?
      # Generate a random 10-char string for the meeting ID
      meeting_id = SecureRandom.alphanumeric(10).scan(/.{3}/).join('-')
      @resource_booking.meeting_link = "https://meet.google.com/#{meeting_id}"
    end

    if @resource_booking.update(status: :approved, admin_note: params[:admin_note])
      BookingMailer.booking_status_email(@resource_booking).deliver_later
      # Mentor Feedback: Schedule a reminder email at the start time
      SendBookingReminderJob.set(wait_until: @resource_booking.start_time).perform_later(@resource_booking.id)
      render json: @resource_booking
    else
      render json: @resource_booking.errors, status: :unprocessable_entity
    end
  end

  # PATCH /resource_bookings/:id/reject - (Admin only)
  def reject
    if @resource_booking.update(status: :rejected, admin_note: params[:admin_note])
      BookingMailer.booking_status_email(@resource_booking).deliver_later
      alternatives = OfficeResource.suggest_alternatives(
        @resource_booking.office_resource.resource_type,
        @resource_booking.start_time,
        @resource_booking.end_time
      )
      render json: { booking: @resource_booking, suggestions: alternatives }
    else
      render json: @resource_booking.errors, status: :unprocessable_entity
    end
  end

  # PATCH /resource_bookings/:id/check_in - Employee arrival.
  def check_in
    unless @resource_booking.approved?
      return render json: { error: "Booking must be approved before checking in" }, status: :unprocessable_entity
    end

    if @resource_booking.update(checked_in_at: Time.current)
      AuditLog.log(@resource_booking, "check_in", "User checked in to the resource.")
      render json: @resource_booking
    else
      render json: @resource_booking.errors, status: :unprocessable_entity
    end
  end

  # DELETE /resource_bookings/:id - Cancel a booking.
  def destroy
    if @resource_booking.soft_delete
      AuditLog.log(@resource_booking, "canceled", "Booking was canceled by #{current_user.admin? ? 'Admin' : 'User'}.")
      head :no_content
    else
      render json: { error: "Failed to cancel booking" }, status: :unprocessable_entity
    end
  end

  # GET /resource_bookings/:id/quick_check_in
  # Simple action for one-click email confirmation.
  def quick_check_in
    if @resource_booking.update(checked_in_at: Time.current)
      render plain: "Thank you! Your check-in is confirmed."
    else
      render plain: "Error: Could not check in.", status: :unprocessable_entity
    end
  end

  # GET /resource_bookings/:id/quick_cancel
  # Simple action for one-click email cancellation.
  def quick_cancel
    if @resource_booking.soft_delete
      render plain: "Your booking has been cancelled successfully."
    else
      render plain: "Error: Could not cancel booking.", status: :unprocessable_entity
    end
  end

  # GET /resource_bookings/availability
  def availability
    # This action is authorize_resource'd via collection authorization in Ability.rb
    resources = OfficeResource.where(status: :active)
    if params[:resource_type]
      resources = resources.where(resource_type: params[:resource_type])
    end
    render json: resources
  end

  private

  def resource_booking_params
    params.require(:resource_booking).permit(:office_resource_id, :start_time, :end_time)
  end
end
