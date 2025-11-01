import { useState, useEffect, useContext } from "react";
import { useParams } from "react-router";
import { QRCode } from 'react-qrcode-logo';
import AuthContext from "../context/authContext";
import { fetchEventById } from "../api/event";
import { createRegistration } from "../api/registration";
import { BackButton, formatDate } from "../constants/constant";

const EventDetails = () => {
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const { eventId } = useParams();
  const [event, setEvent] = useState(null);
  const [registrationCode, setRegistrationCode] = useState(null);

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

  // ---------- DISPLAY QR CODE ----------
  const displayQRCode = (qrCodeData) => {
    // --- Open QR code in new window ---
    const qrWindow = window.open("");
    qrWindow.document.write(`<img src="${qrCodeData}" alt="QR Code" />`);
  };

  // ---------- BUY TICKET ----------
  const buyTicket = async (ticketTypeId) => {
    // --- Double check user is logged in ---
    if (!user) alert("Please log in to buy tickets.");
    const registrationData = {
      user_id: user.id,
      event_id: event.id,
      ticket_type_id: ticketTypeId,
      qr_code: null
    };

    try {
      const response = await createRegistration(registrationData, token);
      if (!response) throw new Error("Failed to create registration");
      console.log("createRegistration response:", response);
      alert(`Registration has been created! \n Your registration code: ${response.registration.registration_code}`);

      // --- Display QR code ---
      // displayQRCode(response.registration.qr_code);
      // --- Set registration_code ---
      setRegistrationCode(response.registration.registration_code);

    } catch (err) {
      console.error("Error creating registration:", err);
      alert("Error creating registration: " + (err?.response?.data?.message || err.message));
    }
  };

  if (loading) return <div>Loading...</div>;
  if (!event) return <div>Event not found</div>;

  return (
    <div className="EventDetails">
      <BackButton />
      <h1>{event.title}</h1>
      <p>{event.description}</p>
      
      {/* ---------- DISPLAY VENUE DETAILS ---------- */}
      {event.venue.name === "Virtual" ? (
        <div className="venueDetails">
          <h3>Venue: Virtual Event</h3>
        </div>
        ): (
          <div className="venueDetails">
            <h3>Venue: {event.venue.name}</h3>
            <div className="venueLocation">
              <span>Address:</span>
              <div className="addressBlock">
                <p>{event.venue.address}</p>
                <p>{event.venue.city}, {event.venue.state}</p>
                <p>{event.venue.country}, {event.venue.zip_code}</p>
              </div>
            </div>
            <p>Venue Capacity: {event.venue.capacity ? `${event.venue.capacity} people` : 'N/A'}</p>
          </div>
        )}
      <p>From: {formatDate(event.start_date)} - {formatDate(event.end_date)}</p>
      <p>Organizer: {event.organizer ? `${event.organizer.f_name} ${event.organizer.l_name}` : 'N/A'}</p>
      <p>Capacity: {event.capacity}</p>

      {/* ---------- DISPLAY TICKET TYPES ---------- */}
      {event.ticketTypes && event.ticketTypes.length > 0 ? (
        <div className="ticketTypes">
          <h3>Ticket Types:</h3>
          <ul className="ticketTypesList">
            {event.ticketTypes.map((ticket) => (
              <li key={ticket.id} className="ticketListItem">
                <div className="ticketInfo">
                  <span><strong>{ticket.name}</strong></span>
                  <span>{" - "} Price: ${ticket.price}</span>
                  <span>{", "} Quantity: {ticket.quantity}</span>
                </div>
                <button className="buyBtn" onClick={() => buyTicket(ticket.id)}>
                  Buy
                </button>
              </li>
            ))}
          </ul>
        </div>
      ) : (
        <p>No ticket types available.</p>
      )}

      {/* ---------- DISPLAY QR CODE ---------- */}
      {registrationCode && (
        <div>
          <h3>Your QR Code:</h3>
          <QRCode value={registrationCode} size={200} />
        </div>
      )}
    </div>
  );
};

export default EventDetails;