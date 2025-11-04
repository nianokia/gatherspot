# GatherSpot

GatherSpot is a full-stack event management platform for organizers, vendors, and attendees. It enables ticketing, registration, real-time event updates, analytics, and reporting—all powered by a PostgreSQL database, Express.js backend, and a modern React + Vite frontend.

## ✨ Features

### 🎟️ Registration & Ticketing
- Browse and register for events
- Receive QR code tickets for entry
- Manage event registrations and waitlist

### 🔔 Real-Time Event Updates
- Live notifications for schedule changes, venue updates, and announcements
- Push notifications (Firebase Cloud Messaging) and email alerts (SendGrid)

### 🛎️ Check-In & Attendance Tracking (_in development_)
- QR code scanning system for event entry (_in dev_)
- Real-time attendance monitoring (_in dev_)
- Capacity management with waitlist functionality

### 📊 Analytics & Reporting Dashboard (_in development_)
- Ticket sales, attendance, revenue, and feedback analytics
- Exportable reports for organizers

---

## 🧰 Technologies Used

### Frontend
![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)
![Vite](https://img.shields.io/badge/vite-%23646CFF.svg?style=for-the-badge&logo=vite&logoColor=white)
![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=for-the-badge&logo=javascript&logoColor=%23F7DF1E)

### Backend
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Sequelize](https://img.shields.io/badge/sequelize-323330?style=for-the-badge&logo=sequelize&logoColor=blue)
![Nodemon](https://img.shields.io/badge/NODEMON-%23323330.svg?style=for-the-badge&logo=nodemon&logoColor=%BBDEAD)
![Twilio](https://img.shields.io/badge/Twilio-F22F46?style=for-the-badge&logo=Twilio&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-a08021?style=for-the-badge&logo=firebase&logoColor=ffcd34)

---

## ⚙️ Dependencies Overview

| Package | Purpose |
|----------|----------|
| **React / Vite** | Frontend framework & dev environment |
| **Axios** | Handles HTTP requests between frontend & backend |
| **Express.js** | Web framework for routing & middleware handling |
| **Sequelize** | ORM for interacting with PostgreSQL database |
| **pg / pg-hstore** | PostgreSQL driver & data serialization |
| **bcrypt** | Password hashing for user authentication |
| **jsonwebtoken (JWT)** | Secure token-based authentication |
| **dotenv** | Loads environment variables from `.env` file |
| **cors** | Enables cross-origin resource sharing |
| **nodemon** | Auto-restarts server when backend files change |
| **firebase-admin** | Backend push notifications (FCM) |
| **@sendgrid/mail** | Email notifications |
| **qrcode** | QR code generation for tickets |


---

## 🎬 Demo
![demo](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExOXpoenphZ2F5M2xmODhhMW5vMjlhazEwd3F2ZnV2ZXVhbmJnczVjaCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/XQvPP6KJ3k9A8LLAH3/giphy.gif)

---
## 🗄️ Database Setup

**Database:** PostgreSQL  
**ORM:** Sequelize

### Schema Overview

## 🔐 Authentication & Authorization


GatherSpot uses JWT-based authentication and role-based authorization:

- Passwords are securely hashed.
- Users log in to receive a JWT token.
- Protected API routes require a valid JWT.
- Roles (admin, organizer, vendor, attendee) control access to features.
- Frontend uses React Context for auth state and role checks.

-----------

The application uses the following tables:

| Table | Description |
|--------|--------------|
| **users** | Stores user data (organizer, vendor, attendee) |
| **roles** | User roles (admin, organizer, vendor, attendee) |
| **events** | Event details, venue, organizer |
| **event_vendors** | Links vendors to events |
| **event_metrics** | Aggregated analytics for each event |
| **registrations** | Attendee event registrations |
| **ticket_types** | Ticket options for events |
| **attendance** | Tracks check-in status |
| **waitlists** | Waitlist management |
| **notifications** | Event notifications (push, email, in-app) |
| **vendors** | Vendor details |
| **venues** | Venue details |
| **sessions** | Event sessions/schedules |
| **speakers** | Speaker details |
| **session_speakers** | Links speakers to sessions |


**Foreign Key Relationships:**
- `registrations.user_id → users.id`
- `registrations.event_id → events.id`
- `event_metrics.event_id → events.id`
- `attendance.event_id → events.id`
- `attendance.user_id → users.id`

A database dump file (`db/dump.sql`) is included for quick setup.

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
```bash
git clone git@github.com:nianokia/gatherspot.git
```
(Optional) Remove the existing .git history if you want fresh ownership:
```bash
rm -rf .git
```

### 2. Install Dependencies
* **Backend Setup:**
	```bash
	cd server
	npm install
	```
* **Frontend Setup:**
	```bash
	cd client
	npm install
	```

### 3. Environment Variables
Create `.env` files in both `server` and `client` folders.
* **Backend Setup:**
	```bash
	PORT=4000
	DOMAIN='http://localhost:4000/'
	DATABASE_URI='postgresql://localhost/gatherspot'
	JWT_SECRET='yourSecretKey'
	SENDGRID_API_KEY='yourSendGridKey'
	SENDGRID_VERIFIED_SENDER='yourVerifiedSenderEmail'
	GOOGLE_APPLICATION_CREDENTIALS='path/to/firebase-service-account.json'
	```
* **Frontend Setup:**
	```bash
	VITE_DOMAIN='http://localhost:4000'
	VITE_FIREBASE_API_KEY='yourFirebaseApiKey'
	VITE_FIREBASE_MESSAGING_SENDER_ID='yourSenderId'
	VITE_FIREBASE_VAPID_KEY='yourVapidKey'
	```

### 4. Database Setup
1. Create the database:
	```CREATE DATABASE gatherspot;```
2. Restore the DB dump file:
	```psql -U <your_user> -d gatherspot -f server/db/dump.sql```

### 5. Run the App
**Run frontend & backend concurrently:**
```bash
cd server
npm run dev
```
The app should now be running at `http://localhost:5173` (or as specified).

---
## 🧩 Implementation Details

**Backend**
* `server.js` configures Express routes, JWT authentication, and Sequelize models.
* `controllers/` handle CRUD logic for events, users, registrations, ticketing, notifications, analytics, and attendance.
* `models/` define Sequelize models and relationships (User, Event, Registration, TicketType, EventMetric, Attendance, etc.).

**Frontend**
* `EventDetails.jsx` — event info, ticketing, registration, QR code download, waitlist join
* `OrganizerEvents.jsx` — organizer event management
* `AnalyticsDash.jsx` — analytics dashboard (ticket sales, attendance, revenue, feedback)
* `UserProfile.jsx` — user account details
* `context/` — global state management for authentication, notifications, and app-wide data

## 🌐 API Routes Overview
### Auth Routes
|Method | Endpoint | Description |
|-------|----------|--------------|
|POST |/api/auth/register| Register new user |
|POST |/api/auth/login |Login and receive JWT token |
### Event Routes
|Method |Endpoint   | Description |
|-------|----------|--------------|
|GET |/api/events |Fetch all events |
|GET |/api/events/:id |Fetch single event by ID |
|POST |/api/events |Create new event (Organizer only) |
|PUT |/api/events/:id |Update event |
|DELETE |/api/events/:id |Delete event |
### Vendor Routes
|Method |Endpoint |Description |
|-------|----------|--------------|
|GET |/api/vendors |Fetch all vendors |
|GET |/api/vendors/:id |Fetch single vendor |
|POST |/api/vendors |Create vendor |
|PUT |/api/vendors/:id |Update vendor |
|DELETE |/api/vendors/:id |Delete vendor |
### Venue Routes
|Method |Endpoint |Description |
|-------|----------|--------------|
|GET |/api/venues |Fetch all venues |
|GET |/api/venues/:id |Fetch single venue |
|POST |/api/venues |Create venue |
|PUT |/api/venues/:id |Update venue |
|DELETE |/api/venues/:id |Delete venue |
### Speaker Routes
|Method |Endpoint |Description |
|-------|----------|--------------|
|GET |/api/speakers |Fetch all speakers |
|GET |/api/speakers/:id |Fetch single speaker |
|POST |/api/speakers |Create speaker |
|PUT |/api/speakers/:id |Update speaker |
|DELETE |/api/speakers/:id |Delete speaker |
### Waitlist Routes
|Method |Endpoint |Description |
|-------|----------|--------------|
|GET |/api/waitlist/:eventId |Get waitlist for event |
|POST |/api/waitlist |Join waitlist |
|DELETE |/api/waitlist/:id |Remove from waitlist |
### Registration & Ticketing
|Method |Endpoint |Description |
|-------|----------|--------------|
|GET |/api/registrations/:userId |Fetch registrations for a user |
|POST |/api/registrations |Register for event |
|POST |/api/ticket-types/:eventId |Create ticket type |
### Attendance & Check-In
|Method |Endpoint |Description |
|-------|----------|--------------|
|POST |/api/events/:eventId/check-in |Check-in attendee (QR code) |
|GET |/api/events/:eventId/attendance |Get attendance list |
### Analytics
|Method |Endpoint |Description |
|-------|----------|--------------|
|GET |/api/analytics/:eventId/metrics |Aggregated event metrics |
|GET |/api/analytics/:eventId/ticket-sales |Ticket sales |
|GET |/api/analytics/:eventId/attendee |Attendance |
|GET |/api/analytics/:eventId/revenue |Revenue |
|GET |/api/analytics/:eventId/no-show |No-show count |
### Notification
|Method |Endpoint |Description |
|-------|----------|--------------|
|POST |/api/notifications |Create notification |
|GET |/api/notifications/:eventId |Get notifications for event |

## 🛸 Future Implementations
* Third-party styling (Bootstrap/Tailwind)
* Check-In & Attendance Tracking

## 📚 Resources
* [Vite Documentation](https://vitejs.dev/)
* [Express Documentation](https://expressjs.com/)
* [Sequelize Documentation](https://sequelize.org/)
* [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
* [SendGrid Email API](https://docs.sendgrid.com/)

## 👩‍💻 About the Developer
Nia Wright is a software engineer who primarily works with HTML, CSS, Javascript, and React. Check out her other [projects](https://niawright.netlify.app/)!

## 📄 License

MIT License

This project is open-source and licensed under the MIT License.