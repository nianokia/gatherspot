import { useState, useEffect, useContext } from "react";
import AuthContext from "../context/authContext";
import { fetchEvents } from "../api/event";
import { formatDate } from "../constants/constant";

const AllEvents = () => {
  const { token } = useContext(AuthContext);
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

  return (
    <div className="AllEvents">
      <h1>All Events Page</h1>
      <ul className="allEventsList">
        {events.map((event) => (
          <li key={event.id} value={event.id} className="singleEvent">
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
      </ul>
    </div>
  );
};

export default AllEvents;