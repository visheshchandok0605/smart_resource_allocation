require "test_helper"

class ResourceBookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:employee)
    @admin = users(:admin)
    @resource = office_resources(:room)
    @base_time = Time.zone.parse("2026-02-09 10:00:00")
  end

  test "should get index when authenticated" do
    get resource_bookings_url, headers: auth_headers(@user), as: :json
    assert_response :success
  end

  test "should not get index when unauthenticated" do
    get resource_bookings_url, as: :json
    assert_response :unauthorized
  end

  test "should create booking" do
    assert_difference("ResourceBooking.count") do
      post resource_bookings_url, 
           params: { resource_booking: { office_resource_id: @resource.id, start_time: @base_time, end_time: @base_time + 1.hour } },
           headers: auth_headers(@user), 
           as: :json
    end
    assert_response :created
  end

  test "should return alternatives when resource is busy" do
    # Create an existing booking
    ResourceBooking.create!(
      user: @admin,
      office_resource: @resource,
      start_time: @base_time,
      end_time: @base_time + 1.hour,
      status: :approved
    )

    # Create another available room
    OfficeResource.create!(name: "Alternative Room", resource_type: :room, status: :active)

    post resource_bookings_url, 
         params: { resource_booking: { office_resource_id: @resource.id, start_time: @base_time, end_time: @base_time + 1.hour } },
         headers: auth_headers(@user), 
         as: :json
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "This resource is already booked for the selected time slot"
    assert_not_empty json_response["suggested_alternatives"]
  end

  test "employee can see their own booking but not others (covered by index check)" do
    # This logic is mostly in Ability.rb, but let's test the endpoint
    my_booking = ResourceBooking.create!(user: @user, office_resource: @resource, start_time: @base_time, end_time: @base_time + 1.hour, status: :pending)
    other_user = User.create!(name: "Other", email: "other@example.com", password: "password", role: :employee, employee_id: "EMP999")
    other_booking = ResourceBooking.create!(user: other_user, office_resource: @resource, start_time: @base_time + 2.hours, end_time: @base_time + 3.hours, status: :pending)

    get resource_bookings_url, headers: auth_headers(@user), as: :json
    bookings = JSON.parse(response.body)
    
    assert_includes bookings.map { |b| b["id"] }, my_booking.id
    assert_not_includes bookings.map { |b| b["id"] }, other_booking.id
  end
end
