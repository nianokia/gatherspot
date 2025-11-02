import { useState, useEffect, useContext, useRef } from "react";
import { useParams, useNavigate } from "react-router";
import { QRCode } from 'react-qrcode-logo';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPenToSquare, faTrash } from '@fortawesome/free-solid-svg-icons';
import AuthContext from "../context/authContext";
import { fetchEventById, deleteEvent } from "../api/event";
import { createRegistration, fetchRegistrationsByUser } from "../api/registration";
import { addToWaitlist } from "../api/waitlist";
import EditEvent from "../pages/EditEvent.jsx";
import { BackButton, Modal, ConfirmModal, OptionsModal, formatDate } from "../constants/constant";

const EventDetails = () => {
  const navigate = useNavigate();
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const { eventId } = useParams();
  const [event, setEvent] = useState(null);

  // ---------- MODAL STATES ----------
  const [isEditOptionsOpen, setIsEditOptionsOpen] = useState(false);
  const [isEditEventOpen, setIsEditEventOpen] = useState(false);
  const [isEditVenueOpen, setIsEditVenueOpen] = useState(false);
  const [isEditTicketTypesOpen, setIsEditTicketTypesOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);

  // ---------- REGISTRATION STATES ----------
  const [existingRegistrations, setExistingRegistrations] = useState(null);
  const [registration, setRegistration] = useState(null);
  const [registrationCode, setRegistrationCode] = useState(null);
  const [isEventFull, setIsEventFull] = useState(false);
  
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

  // ---------- JOIN WAITLIST ----------
  const handleJoinWaitlist = async () => {
    // --- Double check user is logged in ---
    if (!user) alert("Please log in to buy tickets.");
    const waitlistData = { user_id: user.id, event_id: event.id, status: 'waiting' };

    try {
      const response = await addToWaitlist(waitlistData, token);
      if (!response) throw new Error("Failed to join waitlist");
      console.log("addToWaitlist response:", response);
      alert("You have been added to the waitlist!");
    } catch (err) {
      console.error("Error joining waitlist:", err);
      alert("Error joining waitlist: " + (err?.response?.data?.message || err.message));
    }
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
      // ---------- CREATE REGISTRATION ----------
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

  // --- dynamically display updated Course ---
  const handleUpdatedCourse = (updatedCourse) => {
    setCourse(updatedCourse);
  };

  // ---------- HANDLE EDIT OPTIONS ----------
  const handleEditOptions = (action) => {
    if (action === "editEvent") {
      setIsEditOptionsOpen(false);
      setIsEditEventOpen(true);
    } else if (action === "editVenue") {
      setIsEditOptionsOpen(false);
      setIsEditVenueOpen(true);
    } else if (action === "editTicketTypes") {
      setIsEditOptionsOpen(false);
      setIsEditTicketTypesOpen(true);
    }
  };

  // ---------- DELETE EVENT ----------
  const handleDelete = async (eventId) => {
    try {
      await deleteEvent(eventId, token);
      alert(`${event?.title ?? "Title"} has been deleted successfully!`);
      navigate(-1); 
    } catch (err) {
      alert('Failed to delete event. Please try again.');
      console.error('Error deleting event: ', err)
    }
  };

  // ---------- ALL USE EFFECTS ----------
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

  // --- check if event is full ---
  useEffect(() => {
    if (event && event.ticketTypes) {
      setIsEventFull(event.capacity <= (event.registrations ? event.registrations.length : 0));
    }
  }, [event]);

  // ---------- CONDITIONAL RENDERING ----------
  if (loading) return <div>Loading...</div>;
  if (!event) return <div>Event not found</div>;

  return (
    <div className="EventDetails">
      <BackButton />
      <header>
        {user && (user.role_id === 1 || user.role_id === 4) && (
          <div className="eventIconGroup">
              <FontAwesomeIcon
                icon={faPenToSquare}
                className="editIcon"
                onClick={() => setIsEditOptionsOpen(true)}
              />
            <FontAwesomeIcon icon={faTrash} 
              className="deleteEventItem"
              onClick={() => setIsDeleteModalOpen(true)}
            />
          </div>
        )}
        <h1>{event.title}</h1>
        <p>{event.description}</p>
      </header>

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
        isEventFull ? (
          <div>
            <p>Event is full. Would you like to join the waitlist?</p>
            <button onClick={handleJoinWaitlist}>Join Waitlist</button>
          </div>
        ) : event.ticketTypes && event.ticketTypes.length > 0 ? (
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

      {/* ---------- OPTIONS MODAL ---------- */}
      <OptionsModal
        isOpen={isEditOptionsOpen}
        onClose={() => setIsEditOptionsOpen(false)}
        title="What would you like to edit?"
        action1={() => handleEditOptions("editEvent")}
        action2={() => handleEditOptions("editVenue")}
        action3={() => handleEditOptions("editTicketTypes")}
        option1="Edit Event Details"
        option2="Edit Venue"
        option3="Edit Ticket Types"
      />

      {/* ---------- EDIT EVENT MODAL ---------- */}
      <Modal isOpen={isEditEventOpen} onClose={() => setIsEditEventOpen(false)}>
        <EditEvent 
          eventId={eventId}
          setIsModalOpen={setIsEditEventOpen}
          onEventUpdated={handleUpdatedCourse}
          event={event}
          token={token}
          onUpdate={fetchEvent}
          onClose={() => setIsEditEventOpen(false)}
        />
      </Modal>

      {/* ---------- EDIT VENUE MODAL ---------- */}
      {/* TODO: Add EditVenue component/modal here */}
      {/* <Modal isOpen={isEditVenueOpen} onClose={() => setIsEditVenueOpen(false)}>
        <EditVenue ... />
      </Modal> */}

      {/* ---------- EDIT TICKET TYPES MODAL ---------- */}
      {/* TODO: Add EditTicketTypes component/modal here */}
      {/* <Modal isOpen={isEditTicketTypesOpen} onClose={() => setIsEditTicketTypesOpen(false)}>
        <EditTicketTypes ... />
      </Modal> */}

      {/* ---------- DELETE EVENT MODAL ---------- */}
      <ConfirmModal 
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        onConfirm={() => handleDelete(event.id)}
        title={`Are you sure you want to delete "${event.title}"?`}
        message={`This action will permanently delete (${event.title}) from the database.`}
        confirmText="Yes, Delete"
        cancelText="No, Cancel"
      />
    </div>
  );
};

export default EventDetails;