import { useContext } from 'react';
import { Link } from 'react-router';
import AuthContext from '../context/authContext.jsx';
import AllEvents from '../components/AllEvents.jsx';

const AdminDash = () => {
  const { logout } = useContext(AuthContext);

  return (
    <div className="AdminDash">
      <h1>Admin Dashboard</h1>
      <h3>Click any event to manage event details</h3>
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
      <AllEvents />
      <br />
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default AdminDash;