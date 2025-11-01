import { Routes, Route } from 'react-router'
import './App.css'

import NavBar from './components/NavBar.jsx'
import StartPage from './pages/StartPage.jsx'
import SignUp from './pages/SignUp.jsx'
import OrganizerDash from './pages/OrganizerDash.jsx'
import OrganizerEvents from './components/OrganizerEvents.jsx'
import AttendeeDash from './pages/AttendeeDash.jsx'
import AttendeeEvents from './components/AttendeeEvents.jsx'
import VendorDash from './pages/VendorDash.jsx'
import AdminDash from './pages/AdminDash.jsx'
import EventDetails from './components/EventDetails.jsx'
import AddEvent from './pages/AddEvent.jsx'
import AddVenue from './pages/AddVenue.jsx'
import AddTicketType from './pages/AddTicketType.jsx'

function App() {
  return (
    <div className='App'>
      <NavBar />
      <div className="AppContainer">
        <Routes>
          <Route path="/" element={<StartPage />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/organizer" element={<OrganizerDash />} />
          <Route path="/organizer/:organizerId" element={<OrganizerEvents />} />
          <Route path="/attendee" element={<AttendeeDash />} />
          <Route path="/attendee/:attendeeId" element={<AttendeeEvents />} />
          <Route path="/vendor" element={<VendorDash />} />
          <Route path="/admin" element={<AdminDash />} />
          <Route path="/:eventId" element={<EventDetails />} />
          <Route path="/add-event" element={<AddEvent />} />
          <Route path="/add-venue" element={<AddVenue />} />
          <Route path="/add-ticket-type/:eventId" element={<AddTicketType />} />
        </Routes>
      </div>
    </div>
  )
}

export default App
