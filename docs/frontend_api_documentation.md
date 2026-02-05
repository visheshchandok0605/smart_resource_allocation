# Frontend API Documentation: Smart Office Management

This document provides the exact routes and specifications for the frontend team. 

## Base URL
- Development: `http://localhost:3000`

## Headers
All authenticated requests must include:
`Authorization: Bearer <JWT_TOKEN>`

---

## 1. Authentication
Endpoints for logging users in and out.

| Method | Endpoint | Description | Payload Example |
| :--- | :--- | :--- | :--- |
| `POST` | `/users/sign_in` | User Login | `{"user": {"email": "...", "password": "..."}}` |
| `DELETE` | `/users/sign_out` | User Logout | (None) + Bearer Token |

---

## 2. Resources (Rooms & Equipment)
Managed by Admins, viewed by everyone.

| Method | Endpoint | Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/office_resources` | All | Get all active resources |
| `GET` | `/office_resources/:id` | All | Get details of one resource |
| `POST` | `/office_resources` | Admin | Create new resource |
| `PATCH` | `/office_resources/:id` | Admin | Update resource details |
| `DELETE` | `/office_resources/:id` | Admin | Soft-delete a resource |

---

## 3. Bookings (The Core Flow)
Employees book items; Admins manage approvals.

| Method | Endpoint | Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/resource_bookings` | All | List bookings (Admins see all, Users see own) |
| `POST` | `/resource_bookings` | All | Create a new booking request |
| `PATCH` | `/resource_bookings/:id/check_in` | Owner | Mark user as arrived |
| `DELETE` | `/resource_bookings/:id` | Owner/Admin | Cancel a booking |
| `PATCH` | `/resource_bookings/:id/approve` | Admin | Approve a pending booking |
| `PATCH` | `/resource_bookings/:id/reject` | Admin | Reject a booking |
| `GET` | `/resource_bookings/availability` | All | Filter by `resource_type` (query param) |

---

## 4. Admin Management & Reports
Restricted to users with `role: "admin"`.

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/users` | List all system users |
| `POST` | `/users` | Create new employee/admin |
| `GET` | `/reports/dashboard` | Get system utilization analytics |

---

## Data Structures

### User Object
```json
{
  "id": 1,
  "name": "Admin",
  "email": "admin@example.com",
  "role": "admin",
  "employee_id": "ADMIN001"
}
```

### Resource Booking (Payload)
```json
{
  "office_resource_id": 5,
  "start_time": "2026-02-10T09:00:00Z",
  "end_time": "2026-02-10T11:00:00Z"
}
```
