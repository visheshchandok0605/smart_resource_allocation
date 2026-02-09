# Seed specific resources from the requirements
Admin = User.find_or_create_by!(email: "vishesh.chandok@joshsoftware.com") do |u|
  u.name = "Admin User"
  u.password = "password"
  u.role = :admin
end

Employee = User.find_or_create_by!(email: "john@office.com") do |u|
  u.name = "John Doe"
  u.password = "password"
  u.role = :employee
  u.employee_id = "EMP-001"
end

# Meeting Rooms
OfficeResource.create!(name: "Meeting Room A", resource_type: :room, configuration: { capacity: 4 })
OfficeResource.create!(name: "Meeting Room B", resource_type: :room, configuration: { capacity: 8 })

# Equipment
OfficeResource.create!(name: "Pro Laptop", resource_type: :equipment, configuration: { ram: "16GB", os: "macOS", storage: "512GB" })
OfficeResource.create!(name: "Standard Phone", resource_type: :equipment, configuration: { os: "Android", model: "Pixel 6" })

# Turf
OfficeResource.create!(name: "West Wing Turf", resource_type: :turf)

puts "Seeds created successfully!"
