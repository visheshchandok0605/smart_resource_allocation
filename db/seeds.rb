# Seed specific resources from the requirements
Admin = User.create!(name: "Admin User", email: "admin@office.com", password: "password", role: :admin)
Employee = User.create!(name: "John Doe", email: "john@office.com", password: "password", role: :employee)

# Meeting Rooms
OfficeResource.create!(name: "Meeting Room A", resource_type: :room, configuration: { capacity: 4 })
OfficeResource.create!(name: "Meeting Room B", resource_type: :room, configuration: { capacity: 8 })

# Equipment
OfficeResource.create!(name: "Pro Laptop", resource_type: :equipment, configuration: { ram: "16GB", os: "macOS", storage: "512GB" })
OfficeResource.create!(name: "Standard Phone", resource_type: :equipment, configuration: { os: "Android", model: "Pixel 6" })

# Turf
OfficeResource.create!(name: "West Wing Turf", resource_type: :turf)

puts "Seeds created successfully!"
