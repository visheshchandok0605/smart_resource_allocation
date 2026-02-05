# The User model represents an employee or admin in our system.
# We inherit from ApplicationRecord, which gives us access to all the Rails database power (ActiveRecord).
class User < ApplicationRecord
  # has_secure_password is a built-in Rails method that:
  # 1. Adds a 'password' and 'password_confirmation' virtual attribute.
  # 2. Uses the 'bcrypt' gem to transform passwords into safe hashes (password_digest).
  # 3. Ensures passwords aren't stored in plain text.
  has_secure_password

  # enum allows us to map names (strings) to numbers (integers) in the database.
  # { employee: 0, admin: 1 } means '0' in the DB is an 'employee'.
  enum :role, { employee: 0, admin: 1 }, default: :employee

  # Validations ensure that bad data never reaches our database.
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # Every user must have a name.
  validates :name, presence: true
  
  # Every user must have a role.
  validates :role, presence: true

  # Every employee must have a unique company ID.
  validates :employee_id, presence: true, uniqueness: true, if: -> { employee? }

  # ASSOCIATIONS
  # One user can have many booking requests.
  has_many :resource_bookings
end
