# Walkthrough: Minimalist Audit & History

I have implemented a lightweight way to track deleted records and automated system actions, satisfying the requirement for an audit trail without excessive complexity.

## Changes Made

### 1. Database & Archiving
- **Soft Deletes**: Added `deleted_at` columns to `OfficeResource` and `ResourceBooking`.
- **Audit Table**: Created a simple `audit_logs` table to store "Major Events".

### 2. Core Logic
- **ApplicationRecord**: Added a `soft_delete` method and a `.kept` scope to all models.
- **AuditLog Model**: A polymorphic model to log events like "deleted" or "auto_released".

### 3. Application Integration
- **OfficeResourcesController**: The `destroy` action now soft-deletes the resource and logs who did it.
- **ReleaseExpiredBookingsJob**: Now logs a "System Auto-Released" event when a booking expires.

### 4. Authentication & Authorization Migration
- **Devise**: Replaced custom login logic with standard Devise authentication for better security and features like password resets.
- **devise-jwt**: Integrated for stateless session handling via JWT tokens.
- **CanCanCan**: Centralized all permission logic in `app/models/ability.rb`, replacing scattered `if admin?` checks.

## Verification Results

### Authentication (Devise)
Verified that users can authenticate using Devise's `valid_password?` method.
```bash
User found/created: admin@example.com
Password valid: true
```

### Authorization (CanCanCan)
Verified that permissions are correctly enforced via the `Ability` model.
- Admins have `manage :all` permissions.
- Employees are restricted to reading resources and managing their own bookings.



## Next Steps
- You can now use the `AuditLog` table for reporting on system activity and deleted resources.
- The `.kept` scope should be used in any new controllers to filter out archived data.
