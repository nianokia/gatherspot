import gsLogo from '/gatherspot-logo.png'
import { Routes, Route, Link } from 'react-router'
import './App.css'

import StartPage from './pages/StartPage.jsx'
import SignUp from './pages/SignUp.jsx'

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
        </Routes>
      </div>
    </div>
  )
}

export default App
