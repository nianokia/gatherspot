import { useState, useEffect, useContext } from 'react';
import { useNavigate, Link } from "react-router";
import { fetchRegistrationsByUser } from '../api/registration.jsx';
import AuthContext from "../context/authContext.jsx";
import { formatDate } from "../constants/constant.jsx";

const AttendeeEvents = () => {
  const { user, token } = useContext(AuthContext);
  const navigate = useNavigate();
  const attendeeId = user?.id;
  const [registrations, setRegistrations] = useState([]);
  const [loading, setLoading] = useState(true);

  // ---------- FETCH REGISTRATIONS FOR ATTENDEE ----------
  const fetchUserRegistrations = async () => {
    try {
      const data = await fetchRegistrationsByUser(attendeeId, token);
      console.log("Fetched registrations for attendee:", data);
      
      // --- registrations array is located in data.registrations ---
      setRegistrations(data.registrations);
      setLoading(false);
    } catch (err) {
      console.error("Error fetching registrations:", err);
    }
  };

  useEffect(() => {
    if (user && token) {
      fetchUserRegistrations();
    }
  }, [user, token]);

  // ---------- CONDITIONAL RENDERING ----------
  if (!user) return <div>Loading user information...</div>;
  if (loading) return <div>Loading registered events...</div>;

  return (
    <div className="AttendeeEvents">
      <h2>My Registered Events</h2>
      {registrations.length === 0 ? (
        <>
          <p>No events registered.</p>
          <button>
            <Link to="/">Browse Events</Link>
          </button>
        </>
        
      ) : (
        <ul className="allEventsList">
          {/* --- ensure all keys are unique (event-UUID) --- */}
          {registrations.map((registration) => (
            <li key={`event-${registration.event.id}`} value={registration.event.id} className="singleEvent" onClick={() => navigate(`/${registration.event.id}`)}>
              <div className="listHeader">
                <h3>{registration.event.title}</h3>
                {/* --- Render delete button for admin --- */}
                {user && (user.role_id === 4) ? (
                  <FontAwesomeIcon icon={faTrash} 
                    className="deleteEventItem" 
                    onClick={(e) => {
                      e.stopPropagation();
                      handleDelete(event.id);
                    }} 
                  />
                ) : ( null )}
              </div>
              <ul>
                <div className="singleEventListGroup">
                  <li>Event Type: {registration.event.event_type}</li><li>Capacity: {registration.event.capacity}</li>
                </div>
                <li>{registration.event.description}</li>
                <div className="singleEventListGroup venueDateBlock">
                  <div className="venueBlock">
                    <li>
                      <ul>
                        <li>{registration.event.venue ? registration.event.venue.name : 'N/A'}</li>
                        <li>{registration.event.venue ? registration.event.venue.address : 'N/A'}</li>
                        <li>{registration.event.venue ? registration.event.venue.city : 'N/A'}, {" "}
                          {registration.event.venue ? registration.event.venue.state : 'N/A'}, {" "}
                          {registration.event.venue ? registration.event.venue.country : 'N/A'}, {" "}
                          {registration.event.venue ? registration.event.venue.zip_code : 'N/A'}
                        </li>
                      </ul>
                    </li>
                    <li>Venue Capacity: {registration.event.venue ? registration.event.venue.capacity : 'N/A'}</li>
                  </div>
                  <div className="dateBlock">
                    <li>Start Date: {formatDate(registration.event.start_date)}</li>
                    <li>End Date: {formatDate(registration.event.end_date)}</li>
                  </div>
                </div>
              </ul>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default AttendeeEvents;