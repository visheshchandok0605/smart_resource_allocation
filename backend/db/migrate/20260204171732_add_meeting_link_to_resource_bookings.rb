class AddMeetingLinkToResourceBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :resource_bookings, :meeting_link, :string
  end
end
