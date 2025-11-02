import { useState, useEffect, useContext, useRef } from "react";
import { useParams } from "react-router";
import { QRCode } from 'react-qrcode-logo';
import AuthContext from "../context/authContext";
import { fetchEventById } from "../api/event";
import { createRegistration, fetchRegistrationsByUser } from "../api/registration";
import { BackButton, formatDate } from "../constants/constant";

const EventDetails = () => {
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const { eventId } = useParams();
  const [event, setEvent] = useState(null);
  const [existingRegistrations, setExistingRegistrations] = useState(null);
  const [registration, setRegistration] = useState(null);
  const [registrationCode, setRegistrationCode] = useState(null);
  
  // --- reference to QR code for downloading ---
  const qrCodeRef = useRef();

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

  // ---------- FETCH EXISTING REGISTRATIONS ----------
  const fetchExistingRegistrations = async () => {
    try {
      const data = await fetchRegistrationsByUser(user.id, token);
      setExistingRegistrations(data.registrations);
      console.log("Fetched existing registrations:", data.registrations);
    } catch (err) {
      console.error("Error fetching existing registrations:", err);
    }
  };

  // --- fetch event details on component mount ---
  useEffect(() => {
    fetchEvent();
  }, [eventId, token]);

  // --- fetch existing registrations if user is attendee ---
  useEffect(() => {
    if (user && token && user.role_id === 2) {
      fetchExistingRegistrations();
    }
  }, [user, token]);

  // --- check for existing registration when registrations or event change ---
  useEffect(() => {
    // --- Check if user already has a registration for this event ---
    if (existingRegistrations && event) {
      // --- Find the registration for this event ---
      const registration = existingRegistrations.find(r => r.event_id === event.id);

      // --- if found, set registration & registration code ---
      if (registration) {
        setRegistrationCode(registration.registration_code);
        setRegistration(registration);
      } else {
        setRegistration(null);
      }
    }
  }, [existingRegistrations, event]);

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
      // --------- CREATE REGISTRATION ----------
      const response = await createRegistration(registrationData, token);
      if (!response) throw new Error("Failed to create registration");
      console.log("createRegistration response:", response);
      alert(`Registration has been created! \n Your registration code: ${response.registration.registration_code}`);

      setRegistrationCode(response.registration.registration_code);
    } catch (err) {
      console.error("Error creating registration:", err);
      alert("Error creating registration: " + (err?.response?.data?.message || err.message));
    }
  };

  // ---------- DOWNLOAD QR CODE ----------
  const handleDownload = () => {
    if (qrCodeRef.current) qrCodeRef.current.download();
  };

  // ---------- CONDITIONAL RENDERING ----------
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

      <hr />
      {/* --- Only show registration block & QR code if registrationCode exists --- */}
      {registrationCode && registration ? (
        // ---------- DISPLAY QR CODE & TICKET TYPE ----------
        <div className="qrCodeContainer">
          <h3>Your Registration</h3>
          <h4>Ticket Type: {registration.ticketType?.name || registration.ticket_type?.name || 'N/A'}</h4>
          <h4>Registration Code: {registrationCode}</h4>
          <QRCode ref={qrCodeRef}
            value={registrationCode}
            logoImage="/gatherspot-logo.png" 
            size={200}
            quietZone={15}
            logoWidth={90}
            logoHeight={25}
            logoPadding={10}
            fgColor="#113B6F"
            bgColor="#f6f6f6"
            logoPaddingStyle="square"
            logoPaddingRadius={30}
            qrStyle="squares"
            eyeColor="#23B9D9"
            eyeRadius={[20, 20, 20, 20]}
          />
          <button type="button" className="downloadBtn" onClick={handleDownload}>
            Download QR Code
          </button>
        </div>
      ) : (
        event.ticketTypes && event.ticketTypes.length > 0 ? (
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
                  {user && user.role_id === 2 && (
                    <button className="buyBtn" onClick={() => buyTicket(ticket.id)}>
                      Buy
                    </button>
                  )}
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <p>No ticket types available.</p>
        )
      )}
    </div>
  );
};

export default EventDetails;