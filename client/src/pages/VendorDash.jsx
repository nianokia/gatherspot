import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const VendorDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="VendorDash">
      <BackButton />
      <h1>Vendor Dashboard</h1>
      <h2>All Events</h2>
      <p>Search, sort, and filter events</p>
      <h2>My Events</h2>
      {/* --- List of events would go here --- */}
      <ul className='userEventList'>
        <li>Clickable Events
          <ul>
            <li className='userEvent'>GET event</li>
            <li className="userEvent">GET sessions</li>
            <li className="userEvent">GET notifications (schedule changes, venue updates, important announcements)</li>
          </ul>
        </li>
      </ul>
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default VendorDash;