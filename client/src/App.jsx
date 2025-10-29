import { useState } from 'react'
import gsLogo from '/gatherspot-logo.png'
import gsIcon from '/gatherspot-icon.png'
import './App.css'

function App() {
  const login = () => {
    console.log('Login button clicked');
    alert('Congratulations! You have logged in successfully.');
  }

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
        <div className="authCard">
          <form onSubmit={login} className="authForm">
            <input type="email" placeholder="Email" required />
            <input type="password" placeholder="Password" required />
            <button type="submit" className="authBtn">Log In</button>
          </form>
          <div className="createAccount">
            <p>Don't have an account?</p>
            <button className="authBtn" onClick={() => alert('Navigate to Sign Up page')}>Sign Up</button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
