import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const AttendeeDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="AttendeeDash">
      <BackButton />
      <h1>Attendee Dashboard</h1>
      <h2>All Events</h2>
      <p>Search, sort, and filter events</p>
      <button>Buy Ticket</button>
      <ul className="userEventList">
        <li className="userEvent">CREATE QR code ticket</li>
        <li className="userEvent">CREATE Payment</li>
      </ul>
      <h2>My Events</h2>
      {/* --- List of events would go here --- */}
      <ul className='userEventList'>
        <li>Clickable Events
          <ul>
            <li className='userEvent'>GET event</li>
            <li className="userEvent">UPDATE registration</li>
            <li className="userEvent">GET sessions</li>
            <li className="userEvent">GET QR code tickets</li>
            <li className="userEvent">GET notifications (schedule changes, venue updates, important announcements)</li>
          </ul>
        </li>
      </ul>
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default AttendeeDash;