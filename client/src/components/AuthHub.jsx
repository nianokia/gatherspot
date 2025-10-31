const AuthHub = () => {
  const login = () => {
    console.log('Login button clicked');
    alert('Congratulations! You have logged in successfully.');
  }
  
  return (
    <div className="authHub">
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
  )
};

export default AuthHub;