# This background job runs periodically to "clean up" the resources.
# It releases items that were booked but the user didn't show up.
class ReleaseExpiredBookingsJob < ApplicationJob
  # Standard queue for background work.
  queue_as :default

  # The 'perform' method is what actually runs when the job executes.
  def perform
    # Mentor Feedback: Removed the 15-minute auto-cancellation grace period.
    # We now default to 'checked-in' if no action is taken.
    # This job can be used in the future for other cleanup tasks.
  end
end
