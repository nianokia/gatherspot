import { useContext } from 'react';
import { Link } from 'react-router';
import AuthContext from '../context/authContext.jsx';
import OrganizerEvents from '../components/OrganizerEvents.jsx';

const OrganizerDash = () => {
  const { logout } = useContext(AuthContext);

  return (
    <div className="OrganizerDash">
      <h1>Organizer Dashboard</h1>
      <div className="createBtns">
        <button>
          <Link to="/add-venue">Create Venue</Link>
        </button>
        <button>
          <Link to="/add-event">Create Event</Link>
        </button>
      </div>
      <br />
      <hr />
      <OrganizerEvents />
      <br />
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default OrganizerDash;