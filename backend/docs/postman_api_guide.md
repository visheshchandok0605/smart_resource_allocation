# Postman API Guide: Smart Office Management

This guide explains how to test all the API endpoints of your Smart Office Resource Management system.

## 1. Authentication (Devise + JWT)

Most endpoints require a **JWT Token**. You get this by logging in.

### [POST] Login
- **URL**: `http://localhost:3000/users/sign_in`
- **Body (JSON)**:
  ```json
  {
    "user": {
      "email": "admin@example.com",
      "password": "password"
    }
  }
  ```
- **Response**: The JWT token will be returned in the `Authorization` header and the user data in the body.

### [DELETE] Logout
- **URL**: `http://localhost:3000/users/sign_out`
- **Header**: `Authorization: Bearer <token>`
- **In Postman**: Go to the **Authorization** tab for any subsequent request, select **Bearer Token**, and paste the token there.

---

## 2. User Management (Admin Only)

### [POST] Create User
- **URL**: `http://localhost:3000/users`
- **Body (JSON)**:
  ```json
  {
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "password",
      "role": "employee",
      "employee_id": "EMP123"
    }
  }
  ```

### [GET] List Users
- **URL**: `http://localhost:3000/users`

---

## 3. Office Resources (Admin = Create/Update/Delete)

### [GET] List Resources
- **URL**: `http://localhost:3000/office_resources`
- **Info**: Shows active, non-deleted meeting rooms and equipment.

### [POST] Create Resource (Admin Only)
- **URL**: `http://localhost:3000/office_resources`
- **Body (JSON)**:
  ```json
  {
    "name": "Conference Room A",
    "resource_type": "meeting_room",
    "status": "active"
  }
  ```

### [DELETE] Soft Delete Resource (Admin Only)
- **URL**: `http://localhost:3000/office_resources/:id`
- **Info**: Marks the resource as deleted but keeps it in the DB for logs.

---

## 4. Resource Bookings (Staff & Admin)

### [GET] My Bookings
- **URL**: `http://localhost:3000/resource_bookings`
- **Info**: Admins see all; Employees see only their own.

### [POST] Create Booking Request
- **URL**: `http://localhost:3000/resource_bookings`
- **Body (JSON)**:
  ```json
  {
    "office_resource_id": 1,
    "start_time": "2026-02-05T10:00:00Z",
    "end_time": "2026-02-05T11:00:00Z"
  }
  ```
- **Pro Tip**: If the resource is already booked, the API will return `422 Unprocessable Entity` with a list of `suggested_alternatives` (like Meeting Room B) that you can book instead!

### [PATCH] Approve Booking (Admin Only)
- **URL**: `http://localhost:3000/resource_bookings/:id/approve`
- **Body (JSON - Optional)**: `{"admin_note": "Approved for team meeting"}`

### [PATCH] Check-In to Booking
- **URL**: `http://localhost:3000/resource_bookings/:id/check_in`
- **Info**: Used by employees when they arrive. Prevents auto-release.

### [DELETE] Cancel Booking
- **URL**: `http://localhost:3000/resource_bookings/:id`
- **Info**: Employees can cancel their own; Admins can cancel any. Uses soft-delete.

---

## 5. Reports & Logs (Admin Only)

### [GET] Dashboard Analytics
- **URL**: `http://localhost:3000/reports/dashboard`
- **Info**: Shows utilization stats, busy hours, and underutilized items.

### [GET] Availability Search
- **URL**: `http://localhost:3000/resource_bookings/availability?resource_type=meeting_room`
- **Info**: Checks what is available for a specific category.

---

## 6. Summary Table

| Method | Endpoint | Access | Purpose |
| :--- | :--- | :--- | :--- |
| **POST** | `/users/sign_in` | Public | Login & Get JWT Token |
| **POST** | `/users` | Admin | Create new employee |
| **GET** | `/users` | Admin | List all company users |
| **GET** | `/office_resources` | All | View available items |
| **POST** | `/resource_bookings` | All | Submit a request |
| **PATCH** | `/resource_bookings/:id/check_in` | User | Check in upon arrival |
| **DELETE** | `/resource_bookings/:id` | Own/Admin | Cancel a booking |
| **PATCH** | `/resource_bookings/:id/approve` | Admin | Approve a request |
| **GET** | `/reports/dashboard` | Admin | View system analytics |
