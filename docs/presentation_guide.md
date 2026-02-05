# Mentorship Presentation: Smart Office Management System

This guide outlines the core flows and technical justifications for your project. Use this structure to explain "The What, The Why, and The How" to your mentors.

---

## 1. Project Overview
**The Problem**: Offices struggle to manage meeting rooms and shared resources efficiently, leading to "ghost bookings" (booked but never used) and scheduling conflicts.
**The Solution**: A RESTful API that enforces strict booking rules, provides real-time availability, and automates resource release.

---

## 2. Code Reading Flow (The Flowchart)
To understand the architecture, mentors should follow this logical path:

![Code Reading Flowchart](/Users/vishesh/.gemini/antigravity/brain/ca797d40-2273-4fb0-9122-de6f6d887257/code_reading_flowchart.png)

---

## 3. The Technical Stack (The "Why")
| Technology | Why we chose it? |
| :--- | :--- |
| **Ruby on Rails** | Fast development, built-in safety, and great "Convention over Configuration." |
| **PostgreSQL** | Reliable relational data storage (ACID compliant). |
| **Devise + JWT** | **Authentication**: Industry-standard, secure, and stateless (perfect for API/Mobile). |
| **CanCanCan** | **Authorization**: Centralizes all permission logic in one file (`ability.rb`), making the app easy to audit and scale. |

---

## 3. Core Business Logic (The "Smart" part)
Explain these special features to show you've thought about real-world usage:
1. **Working Hour Constraints**: Bookings are only allowed between 9:00 AM and 5:00 PM.
2. **Weekend Protection**: Resources cannot be booked on Saturdays or Sundays.
3. **The "Ghost Booking" Solution**:
   - Users must **Check-in** on arrival.
   - If they don't check in within a certain timeframe, a **Background Job** (`ReleaseExpiredBookingsJob`) automatically cancels the booking to free it for others.
4. **Audit Logging**: Every cancellation or deletion is logged in an `AuditLog` table for accountability.
5. **Soft Deletes**: We never truly "delete" resources or bookings; we mark them as deleted so historical data is preserved.

---

## 4. Key User Flows (Step-by-Step)

### A. The Employee Flow
1. **Login**: User authenticates and receives a JWT.
2. **Discover**: GET `/office_resources` to see what's available.
3. **Request**: POST `/resource_bookings` with desired times.
4. **Action**: Once approved, the user PATCHes `/check_in` upon arrival.
5. **Cleanup**: User can DELETE their own booking if they change their mind.

### B. The Admin Flow
1. **Approve/Reject**: Monitor GET `/resource_bookings` and approve requests.
2. **Suggest**: If rejecting, the system automatically suggests alternatives (AI-like helper).
3. **Analytics**: Access `/reports/dashboard` to see which rooms are most popular.
4. **Manage**: Create new resources or register new employees.

---

## 5. Security Architecture
Explain how you protected the app:
- **Authentication**: JWT tokens ensure only logged-in users enter.
- **Scope Protection**: Employees can *only* see and edit their own bookings. They cannot see other people's sensitive data.
- **Input Validation**: Strong parameters prevent "Mass Assignment" attacks.

---

## 6. Future Roadmap (Optional Bonus)
- **Mobile App**: Integration with the current JSON API.
- **Calendar Integration**: Syncing bookings with Google/Outlook calendars.
- **Hardware Integration**: Smart locks or QR codes for checking in.
