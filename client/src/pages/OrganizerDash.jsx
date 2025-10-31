import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const OrganizerDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="OrganizerDash">
      <BackButton />
      <h1>Organizer Dashboard</h1>
      <div className="createBtns">
        <button>
          Create Venue
        </button>
        <button>
          Create Event
        </button>
      </div>
      
      <h2>My Events</h2>
      {/* --- List of events would go here --- */}
      <ul className='userEventList'>
        <li>Clickable Events
          <ul>
            <li className='userEvent'>GET event</li>
            <li className="userEvent">UPDATE event (venue, ticket_types, waitlist)</li>
            <li className="userEvent">GET sessions</li>
            <li className="userEvent">CREATE session (speakers, vendors)</li>
            <li className="userEvent">CREATE notifications (schedule changes, venue updates, important announcements)</li>
            <li className="userEvent">DELETE event</li>
          </ul>
        </li>
      </ul>
      <button>
        View Event Analytics
      </button>
      <ul className='userEventList'>
        <li>Clickable Events
          <ul>
            <li className='userEvent'>GET event_metrics</li>
            <li className="userEvent">GET feedback</li>
            <li className="userEvent">EXPORT report as a file</li>
          </ul>
        </li>
      </ul>
      <br />
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default OrganizerDash;