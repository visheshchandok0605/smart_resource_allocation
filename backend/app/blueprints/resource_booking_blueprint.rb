class ResourceBookingBlueprint < BaseBlueprint
  identifier :id

  fields :start_time, :end_time, :status, :admin_note, :meeting_link, :checked_in_at, :created_at

  association :user, blueprint: UserBlueprint
  association :office_resource, blueprint: OfficeResourceBlueprint
end
