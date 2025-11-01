import { useState, useEffect, useContext } from "react";
import { useNavigate } from "react-router";
import { fetchEventsByOrganizer, deleteEvent } from "../api/event.jsx";
import AuthContext from "../context/authContext.jsx";
import { formatDate } from "../constants/constant.jsx";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrash } from '@fortawesome/free-solid-svg-icons';

const OrganizerEvents = () => {
  const { user, token } = useContext(AuthContext);
  const navigate = useNavigate();
  const organizerId = user?.id;
  const [events, setEvents] = useState([]);

  const fetchEvents = async () => {
    try {
      const data = await fetchEventsByOrganizer(organizerId, token);
      console.log("Fetched events for organizer:", data);

      // --- events array is located in data.events ---
      setEvents(data.events);
    } catch (error) {
      console.error("Error fetching Organizer's events:", error);
    }
  };

  useEffect(() => {
    if (organizerId) {
      fetchEvents();
    }
  }, [organizerId]);

  const handleDelete = async (eventId) => {
    try {
      await deleteEvent(eventId, token);
      alert(`Event has been deleted successfully!`);
      
      // --- refresh events list after deletion ---
      fetchEvents();
    } catch (err) {
      alert('Failed to delete event. Please try again.');
      console.error('Error deleting event: ', err)
    }
  }

  console.log("Rendering Organizer's Events with events state:", events);

  if (!user) {
    return <div>Loading user information...</div>;
  }

  return (
    <div className="OrganizerEvents">
      <h2>{user?.f_name}'s Events</h2>
      {events.length === 0 ? (
        <p>No events found.</p>
      ) : (
        <ul className="allEventsList">
        {/* --- ensure all keys are unique (event-UUID) --- */}
        {events.map((event) => (
          <li key={`event-${event.id}`} value={event.id} className="singleEvent" onClick={() => navigate(`/${event.id}`)}>
            <div className="listHeader">
              <h3>{event.title}</h3>
              <FontAwesomeIcon icon={faTrash} 
                className="deleteEventItem" 
                onClick={(e) => {
                  e.stopPropagation();
                  handleDelete(event.id);
                }} 
              />
            </div>
            <ul>
              <div className="singleEventListGroup">
                <li>Event Type: {event.event_type}</li><li>Capacity: {event.capacity}</li>
              </div>
              <li>{event.description}</li>
              <div className="singleEventListGroup venueDateBlock">
                <div className="venueBlock">
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
                </div>
                <div className="dateBlock">
                  <li>Start Date: {formatDate(event.start_date)}</li>
                  <li>End Date: {formatDate(event.end_date)}</li>
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

export default OrganizerEvents;