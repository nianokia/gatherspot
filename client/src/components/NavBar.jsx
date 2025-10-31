import { useContext } from 'react';
import { Link } from 'react-router';
import gsLogo from '/gatherspot-logo.png';
import AuthContext from '../context/authContext.jsx';

const NavBar = () => {
  const { user, logout } = useContext(AuthContext);
  return (
    <nav className='navBar'>
      {/* --- conditionally navigate based on user role --- */}
      <Link to={user ? (user.role_id === 1 ? '/organizer' 
        : user.role_id === 2 ? '/attendee' 
        : user.role_id === 3 ? '/vendor' 
        : '/admin') 
        : '/home'
      }>
        <img src={gsLogo} className="logo" alt="GatherSpot logo" />
      </Link>
      {/* --- conditionally render logout button or sign up link --- */}
      {user ? (
        <button onClick={logout} className="logoutBtn">Logout</button>
      ) : (
        <Link to="/signup">Sign Up</Link>
      )}
    </nav>
  );
};

export default NavBar;