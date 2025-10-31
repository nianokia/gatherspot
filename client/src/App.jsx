import { useState } from 'react'
import gsLogo from '/gatherspot-logo.png'
import gsIcon from '/gatherspot-icon.png'
import './App.css'

import AuthHub from './components/AuthHub.jsx'

function App() {
  return (
    <div className='App'>
      <nav className='navBar'>
        <img src={gsLogo} className="logo" alt="GatherSpot logo" />
        <a href="/">Sign Up</a>
      </nav>
      <div className="AppContainer">
        <h1>Welcome to GatherSpot!</h1>
        <h2>Your one-stop spot for planning, organizing, and finding events.</h2>
        <h3>Get started by creating an account or logging in.</h3>
        <AuthHub />
      </div>
    </div>
  )
}

export default App
