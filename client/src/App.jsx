import gsLogo from '/gatherspot-logo.png'
import { Routes, Route, Link } from 'react-router'
import './App.css'

import StartPage from './pages/StartPage.jsx'
import SignUp from './pages/SignUp.jsx'
import OrganizerDash from './pages/OrganizerDash.jsx'
import AttendeeDash from './pages/AttendeeDash.jsx'
import VendorDash from './pages/VendorDash.jsx'
import AdminDash from './pages/AdminDash.jsx'

function App() {
  return (
    <div className='App'>
      <nav className='navBar'>
        <img src={gsLogo} className="logo" alt="GatherSpot logo" />
        <Link to="/signup">Sign Up</Link>
      </nav>
      <div className="AppContainer">
        <Routes>
          <Route path="/" element={<StartPage />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/organizer" element={<OrganizerDash />} />
          <Route path="/attendee" element={<AttendeeDash />} />
          <Route path="/vendor" element={<VendorDash />} />
          <Route path="/admin" element={<AdminDash />} />
        </Routes>
      </div>
    </div>
  )
}

export default App
