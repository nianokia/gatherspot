import { useState, useEffect, useContext } from "react";
import { useParams } from "react-router";
import AuthContext from "../context/authContext";
import { fetchEventById } from "../api/event";
import { BackButton, formatDate } from "../constants/constant";

const EventDetails = () => {
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const { eventId } = useParams();
  const [event, setEvent] = useState(null);

  // ---------- FETCH EVENT BY ID ----------
  const fetchEvent = async () => {
      try {
        const eventData = await fetchEventById(eventId, token);
        setEvent(eventData.event);
        console.log("Fetched event:", eventData.event);
      } catch (err) {
        console.error("Error fetching event:", err);
      } finally {
        setLoading(false);
      }
    };

  useEffect(() => {
    fetchEvent();
  }, [eventId, token]);

  if (loading) return <div>Loading...</div>;
  if (!event) return <div>Event not found</div>;

  return (
    <div className="EventDetails">
      <BackButton />
      <h1>{event.title}</h1>
      <p>{event.description}</p>
      <div className="venueDetails">
        <h3>Venue: {event.venue.name}</h3>
        <div className="venueLocation">
          <p>Address:</p>
          <div className="addressBlock">
            <p>{event.venue.address}</p>
            <p>{event.venue.city}, {event.venue.state}</p>
            <p>{event.venue.country}, {event.venue.zip_code}</p>
          </div>
        </div>
        <p>Venue Capacity: {event.venue.capacity ? `${event.venue.capacity} people` : 'N/A'}</p>
      </div>
      <p>From: {formatDate(event.start_date)} - {formatDate(event.end_date)}</p>
      <p>Organizer: {event.organizer ? `${event.organizer.f_name} ${event.organizer.l_name}` : 'N/A'}</p>
      <p>Capacity: {event.capacity}</p>
    </div>
  );
};

export default EventDetails;