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
        ))}
      </ul>
      {/* <ul className="allEventsList">
        {events.map((event) => (
          <li key={event.id} value={event.id} className="singleEvent" onClick={() => navigate(`/${event.id}`)}>
            <h3>{event.title}</h3>
            <ul>
              <li>Event Type: {event.event_type}</li>
              <li>Description: {event.description}</li>
              <li>Venue: {event.venue ? event.venue.name : 'N/A'}
                <ul>
                  <li>Address: {event.venue ? event.venue.address : 'N/A'}</li>
                  <li>City: {event.venue ? event.venue.city : 'N/A'}</li>
                  <li>State: {event.venue ? event.venue.state : 'N/A'}</li>
                  <li>Country: {event.venue ? event.venue.country : 'N/A'}</li>
                  <li>Zip Code: {event.venue ? event.venue.zip_code : 'N/A'}</li>
                  <li>Capacity: {event.venue ? event.venue.capacity : 'N/A'}</li>
                </ul>
              </li>
              <li>Start Date: {formatDate(event.start_date)}</li>
              <li>End Date: {formatDate(event.end_date)}</li>
              <li>Created by: {event.organizer ? `${event.organizer.f_name} ${event.organizer.l_name}` : 'N/A'}</li>
              <li>Capacity: {event.capacity}</li>
            </ul>
          </li>
        ))}
      </ul> */}
    </div>
  );
};

export default AllEvents;