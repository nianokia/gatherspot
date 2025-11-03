import { useContext } from 'react';
import AuthContext from '../context/authContext.jsx';
import AttendeeEvents from '../components/AttendeeEvents.jsx';

const AttendeeDash = () => {
  const { logout, loading } = useContext(AuthContext);
  return (
    <div className="AttendeeDash">
      <h1>Attendee Dashboard</h1>
      <hr />
      {loading ? (
        <div>Loading...</div>
      ) : (
        <>
          
          <AttendeeEvents />
        </>
      )}
      
      <br />
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default AttendeeDash;