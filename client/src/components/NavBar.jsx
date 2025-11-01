import { useContext } from 'react';
import { Link } from 'react-router';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faBars } from '@fortawesome/free-solid-svg-icons';
import gsLogo from '/gatherspot-logo.png';
import AuthContext from '../context/authContext.jsx';

const NavBar = () => {
  const { user, logout } = useContext(AuthContext);

  // ----------- OPEN NAV MENU -----------
  const openMenu = () => {
    const navLinks = document.querySelector('.navLinks');
    if (navLinks.classList) {
      navLinks.classList.toggle('open');
    }
  };

  return (
    <nav className='navBar'>
      <Link to="/">
        <img src={gsLogo} className="logo" alt="GatherSpot logo" />
      </Link>
      {/* --- conditionally render menu navLinks based on if user exists and their role --- */}
      {user ? (
        <div className="navGroup">
          <button onClick={logout} className="logoutBtn">Logout</button>
          <div className="navLinks">
            {user.role_id === 1 && (
              <>
                <Link to="/organizer">Dashboard</Link>
                <Link to="/add-event">Add Event</Link>
                <Link to="/add-venue">Add Venue</Link>
              </>
            )}
            {user.role_id === 2 && (
              <>
                <Link to="/attendee">Dashboard</Link>
              </>
            )}
            {user.role_id === 3 && (
              <>
                <Link to="/vendor">Dashboard</Link>
              </>
            )}
            {user.role_id === 4 && (
              <>
                <Link to="/admin">Dashboard</Link>
                <Link to="/add-event">Add Event</Link>
                <Link to="/add-venue">Add Venue</Link>
              </>
            )}
          </div>
          <FontAwesomeIcon icon={faBars} className='menuIcon' onClick={openMenu}/>
        </div>
      ) : (
        <Link to="/signup">Sign Up</Link>
      )}
    </nav>
  );
};

export default NavBar;