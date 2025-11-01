import { useState, useEffect, useContext } from "react";
import { useNavigate } from "react-router";
import AuthContext from "../context/authContext";
import { fetchEvents, deleteEvent } from "../api/event";
import { formatDate } from "../constants/constant";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrash } from '@fortawesome/free-solid-svg-icons';

const AllEvents = () => {
  const { user, token } = useContext(AuthContext);
  const navigate = useNavigate();
  const [events, setEvents] = useState([]);

  // ---------- LOAD ALL EVENTS ----------
  const loadEvents = async () => {
    try {
      const data = await fetchEvents(token);

      // --- events array is located in data.events ---
      setEvents(data.events);
    } catch (err) {
      console.error("Error fetching events: ", err);
      alert("Error fetching events: ", err?.response?.data?.message || err.message);
    }
  };

  // --- when component mounts, load events ---
  useEffect(() => {
    loadEvents();
  }, []);

  const handleDelete = async (eventId) => {
    try {
      await deleteEvent(eventId, token);
      alert(`Event has been deleted successfully!`);
      
      // --- refresh events list after deletion ---
      loadEvents();
    } catch (err) {
      alert('Failed to delete event. Please try again.');
      console.error('Error deleting event: ', err)
    }
  }

  console.log("Rendering events state:", events);

  if (!user) {
    return <div>Loading user information...</div>;
  }

  return (
    <div className="AllEvents">
      <h1>All Events Page</h1>
      <ul className="allEventsList">
        {events.length === 0 ? (
          <p>No events found.</p>
        ) : (
          // --- ensure all keys are unique (event-UUID) ---
          (events.map((event) => (
            <li key={`event-${event.id}`} value={event.id} className="singleEvent" onClick={() => navigate(`/${event.id}`)}>
              <div className="listHeader">
                <h3>{event.title}</h3>
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
                  <li>Event Type: {event.event_type}</li><li>Capacity: {event.capacity}</li>
                </div>
                <li>{event.description}</li>
                <div className="singleEventListGroup venueDateBlock">
                  <div className="venueBlock">
                    {event.venue.name === "Virtual" ? (
                      <li id="virtualEvent">Venue: Virtual Event</li>
                    ) : (
                      <>
                        <li>
                          <ul>
                            <li>{event.venue ? event.venue.name : 'N/A'}</li>
                            <li>{event.venue ? event.venue.address : 'N/A'}</li>
                            <li>{event.venue ? event.venue.city : 'N/A'}, {" "}
                              {event.venue ? event.venue.state : 'N/A'}, {" "}
                              {event.venue ? event.venue.country : 'N/A'}, {" "}
                              {event.venue ? event.venue.zip_code : 'N/A'}
                            </li>
                          </ul>
                        </li>
                        <li>Venue Capacity: {event.venue ? event.venue.capacity : 'N/A'}</li>
                      </>
                    )}
                  </div>
                  <div className="dateBlock">
                    <strong>Dates:</strong>
                    <li>{formatDate(event.start_date)}</li>
                    <span id="dateHyphen">-</span>
                    <li>{formatDate(event.end_date)}</li>
                  </div>
                </div>
              </ul>
            </li>
          )))
        )}
      </ul>
    </div>
  );
};

export default AllEvents;