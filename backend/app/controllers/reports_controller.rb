# ReportsController provides insights into how resources are being used.
class ReportsController < ApplicationController
  # Since this controller doesn't have a model, we use authorize_resource class: false
  authorize_resource class: false

  # GET /reports/dashboard
  def dashboard
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current.end_of_month

    bookings_scope = ResourceBooking.where(start_time: start_date.beginning_of_day..end_date.end_of_day)

    utilization = OfficeResource.left_joins(:resource_bookings)
                                .where(resource_bookings: { id: [nil, *bookings_scope.pluck(:id)] })
                                .group(:id, :name)
                                .select("office_resources.id, office_resources.name, count(resource_bookings.id) as bookings_count")
                                .order("bookings_count DESC")

    patterns = bookings_scope.group("EXTRACT(HOUR FROM start_time)")
                             .count

    underutilized = utilization.select { |r| r.bookings_count.to_i == 0 }
    overutilized = utilization.first(3)

    render json: {
      utilization: OfficeResourceBlueprint.render_as_hash(utilization),
      booking_patterns: patterns,
      underutilized: OfficeResourceBlueprint.render_as_hash(underutilized),
      overutilized: OfficeResourceBlueprint.render_as_hash(overutilized)
    }
  end
end
