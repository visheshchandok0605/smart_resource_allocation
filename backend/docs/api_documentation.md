# Master API Documentation: Smart Office Management System

This document provides a complete technical specification for the Smart Office Management API.

## Base URL
- **Local Development**: `http://localhost:3000`

---

## 1. Authentication (Devise + JWT)
The system uses stateless JWT authentication. Every request after login must include the token in the headers.

### [POST] Login
Generates a JWT token for the user.
- **URL**: `/users/sign_in`
- **Payload**:
  ```json
  {
    "user": {
      "email": "admin@example.com",
      "password": "password"
    }
  }
  ```
- **Response**: User data in body; **JWT Token** returned in `Authorization` header.

### [DELETE] Logout
Invalidates the current session token (JTI Revocation).
- **URL**: `/users/sign_out`
- **Header**: `Authorization: Bearer <token>`

---

## 2. Office Resources
Defining rooms, desks, and equipment.

| Method | Endpoint | Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/office_resources` | All | List all active/non-deleted resources. |
| `GET` | `/office_resources/:id` | All | Fetch details for a specific resource. |
| `POST` | `/office_resources` | Admin | Create a new resource (e.g., "Conference Room B"). |
| `PATCH` | `/office_resources/:id` | Admin | Update name, type, or status of a resource. |
| `DELETE` | `/office_resources/:id` | Admin | Soft-delete a resource (removes from list, keeps in logs). |

---

## 3. Resource Bookings (Staff/Employee Flow)
The workflow for reserving office assets.

### [GET] List Bookings
- **URL**: `/resource_bookings`
- **Access**: Employees see only their own; Admins see all.

### [POST] Create Booking
- **URL**: `/resource_bookings`
- **Payload**:
  ```json
  {
    "office_resource_id": 1,
    "start_time": "2026-02-15T09:00:00Z",
    "end_time": "2026-02-15T11:00:00Z"
  }
  ```

### [PATCH] Check-In
- **URL**: `/resource_bookings/:id/check_in`
- **Logic**: User must check in on arrival to prevent the booking from being auto-released.

### [DELETE] Cancel Booking
- **URL**: `/resource_bookings/:id`
- **Logic**: Employees can cancel their own; Admins can cancel any.

---

## 4. Admin Management (Control Panel)
Specific actions restricted to users with `role: "admin"`.

### [PATCH] Approve Request
- **URL**: `/resource_bookings/:id/approve`
- **Payload**: `{"admin_note": "Approved"}`

### [PATCH] Reject Request
- **URL**: `/resource_bookings/:id/reject`
- **Payload**: `{"admin_note": "Room unavailable due to maintenance"}`
- **Note**: The response includes `suggestions` (similar available resources).

### [POST] Create User
- **URL**: `/users`
- **Payload**:
  ```json
  {
    "user": {
      "name": "Jane Doe",
      "email": "jane@example.com",
      "password": "password",
      "role": "employee",
      "employee_id": "EMP555"
    }
  }
  ```

---

## 5. Analytics & Search
Insights and real-time data.

### [GET] Dashboard Reports
- **URL**: `/reports/dashboard`
- **Data Included**: Resource utilization rates, peak hours, and underutilized items.

### [GET] Availability Search
- **URL**: `/resource_bookings/availability`
- **Params**: `?resource_type=meeting_room`
- **Description**: Returns a real-time list of resources that are not currently booked.

---

## Error Codes
- `200 OK`: Request successful.
- `201 Created`: Resource successfully created.
- `401 Unauthorized`: Missing or invalid JWT token.
- `403 Forbidden`: You do not have the required role (Admin/Owner).
- `422 Unprocessable Entity`: Validation failed (e.g., booking outside 9-5 PM).
- `404 Not Found`: Resource or User does not exist.
