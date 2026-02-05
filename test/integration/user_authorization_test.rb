require "test_helper"

class UserAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @employee = users(:employee)
    @admin = users(:admin)
    @resource = office_resources(:room)
    @base_time = Time.zone.parse("2026-02-09 10:00:00")
    @booking = ResourceBooking.create!(user: @employee, office_resource: @resource, start_time: @base_time, end_time: @base_time + 1.hour, status: :pending)
  end

  test "employee cannot approve a booking" do
    patch approve_resource_booking_url(@booking), headers: auth_headers(@employee), as: :json
    assert_response :forbidden
  end

  test "admin can approve a booking" do
    patch approve_resource_booking_url(@booking), params: { admin_note: "Approved by test" }, headers: auth_headers(@admin), as: :json
    assert_response :success
    assert_equal "approved", @booking.reload.status
  end

  test "employee cannot delete another user's booking" do
    other_user = User.create!(name: "Other", email: "other@example.com", password: "password", role: :employee, employee_id: "EMP999")
    other_booking = ResourceBooking.create!(user: other_user, office_resource: @resource, start_time: @base_time + 2.hours, end_time: @base_time + 3.hours, status: :pending)

    delete resource_booking_url(other_booking), headers: auth_headers(@employee), as: :json
    assert_response :forbidden
  end

  test "admin can delete any booking" do
    delete resource_booking_url(@booking), headers: auth_headers(@admin), as: :json
    assert_response :no_content
    assert @booking.reload.deleted_at.present?
  end

  test "employee can delete their own booking" do
    delete resource_booking_url(@booking), headers: auth_headers(@employee), as: :json
    assert_response :no_content
    assert @booking.reload.deleted_at.present?
  end
end
