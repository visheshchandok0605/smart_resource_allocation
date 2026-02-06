class OfficeResourceBlueprint < BaseBlueprint
  identifier :id

  fields :name, :resource_type, :status, :configuration, :created_at
end
