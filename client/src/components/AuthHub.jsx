import { useState, useContext } from "react";
import { Link } from "react-router";
import { loginUser } from "../api/auth.jsx";
import AuthContext from "../context/authContext.jsx";

const AuthHub = () => {
  const { login } = useContext(AuthContext);
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });

  // --- Handle input changes ---
  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      // --- Call login API ---
      const res = await loginUser(formData);
      const { user, token } = res.data;
      // --- Update auth context ---
      login(user, token);
      
      alert('Login successful!');
    } catch (err) {
      console.error('Login failed:', err);
      alert('Login failed. Please try again.');
    }
  };

  return (
    <div className="authHub">
      <form onSubmit={handleSubmit} className="authForm">
        <input type="email" placeholder="Email" required onChange={handleChange} />
        <input type="password" placeholder="Password" required onChange={handleChange} />
        <button type="submit" className="authBtn">Log In</button>
      </form>
      <div className="createAccount">
        <p>Don't have an account?</p>
        <button className="authBtn">
          <Link to="/signup">Sign Up</Link>
        </button>
      </div>
    </div>
  )
};

export default AuthHub;