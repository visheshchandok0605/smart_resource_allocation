# ReportsController provides insights into how resources are being used.
class ReportsController < ApplicationController
  # Since this controller doesn't have a model, we use authorize_resource class: false
  authorize_resource class: false

  # GET /reports/dashboard
  def dashboard
    utilization = OfficeResource.left_joins(:resource_bookings)
                                .group(:id, :name)
                                .select("office_resources.id, office_resources.name, count(resource_bookings.id) as bookings_count")
                                .order("bookings_count DESC")

    patterns = ResourceBooking.group("EXTRACT(HOUR FROM start_time)")
                              .count

    underutilized = utilization.select { |r| r.bookings_count.to_i == 0 }
    overutilized = utilization.first(3)

    render json: {
      utilization: utilization,
      booking_patterns: patterns,
      underutilized: underutilized,
      overutilized: overutilized
    }
  end
end
