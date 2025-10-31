import { useState, useEffect, useContext } from 'react';
import { registerUser } from '../api/auth.jsx';
import AuthContext from "../context/authContext.jsx";
import { BackButton } from '../constants/constant.jsx';

const SignUp = () => {
  const { login } = useContext(AuthContext);
  const [formData, setFormData] = useState({
    role_id: null,
    f_name: '',
    l_name: '',
    phone: '',
    email: '',
    password: '',
    is_active: true
  });
  const [active, setActive] = useState(null);

  // --- Handle input changes ---
  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleRoleSelect = (roleId) => {
    setFormData({
      ...formData,
      role_id: roleId
    });
    setActive(roleId);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      // --- Ensure role is selected ---
      if (!formData.role_id) {
        alert('Please select a role before signing up.');
        return;
      }

      // --- Call register API ---
      const res = await registerUser(formData);
      const { user, token } = res.data;
      // --- Update auth context ---
      login(user, token);

      alert('Registration successful!');
    } catch (err) {
      console.error('Registration failed:', err);
      alert('Registration failed. Please try again.');
    }
  };

  useEffect(() => {
    console.log('Form Data Updated:', formData);
  }, [formData]);

  return (
    <div className='SignUp'>
      <BackButton />
      <h2>Sign Up Page</h2>
      <form onSubmit={handleSubmit} className="authForm">
        <div>
          <label>What is your role?</label>
          <div className="roleBtns">
            <button type="button" id={1} className={active === 1 ? 'active' : ''} onClick={() => handleRoleSelect(1)}>
              Organizer
            </button>
            <button type="button" id={2} className={active === 2 ? 'active' : ''} onClick={() => handleRoleSelect(2)}>
              Attendee
            </button>
            <button type="button" id={3} className={active === 3 ? 'active' : ''} onClick={() => handleRoleSelect(3)}>
              Vendor
            </button>
            <button type="button" id={4} className={active === 4 ? 'active' : ''} onClick={() => handleRoleSelect(4)}>
              Platform Admin
            </button>
          </div>
        </div>
        <input type="text" name="f_name" placeholder="First Name" required onChange={handleChange} />
        <input type="text" name="l_name" placeholder="Last Name" required onChange={handleChange} />
        <input type="tel" name="phone" placeholder="Phone Number" pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}" onChange={handleChange} />
        <input type="email" name="email" placeholder="Email" required onChange={handleChange} />
        <input type="password" name="password" placeholder="Password" required onChange={handleChange} />
        <button type='reset'>Reset</button>
        <button type="submit" className="authBtn">Sign Up</button>
      </form>
    </div>
  )
}

export default SignUp;