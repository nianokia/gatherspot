import { useState, useEffect, useContext, useRef } from "react";
import { useParams, useNavigate } from "react-router";
import { QRCode } from 'react-qrcode-logo';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPenToSquare, faTrash, faStore } from '@fortawesome/free-solid-svg-icons';

import AuthContext from "../context/authContext";
import { fetchEventById, addVendorToEvent, deleteEvent } from "../api/event";
import { createRegistration, fetchRegistrationsByUser, deleteRegistration } from "../api/registration";
import { addToWaitlist } from "../api/waitlist";
import { getSessionsForEvent } from "../api/session.jsx";
import { fetchAllVendors } from "../api/vendor.jsx";

import AddTicketType from "../pages/AddTicketType.jsx";
import AddSession from "../pages/AddSession.jsx";
import AddSpeaker from "../pages/AddSpeaker.jsx";
import AddVendor from "../pages/AddVendor.jsx";
import EditEvent from "../pages/EditEvent.jsx";
import EditVenue from "../pages/EditVenue.jsx";
import EditTicketType from "../pages/EditTicketType.jsx";
import EditSession from "../pages/EditSession.jsx";
import EditSpeaker from "../pages/EditSpeaker.jsx";

import SelectTicketTypeModal from "./SelectTicketTypeModal.jsx";
import SelectSessionModal from "./customModals/SelectSessionModal.jsx";
import DropDownModal from "./customModals/DropDownModal.jsx";

import { BackButton, Modal, ConfirmModal, OptionsModal, formatDate } from "../constants/constant";

const EventDetails = () => {
  const navigate = useNavigate();
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const { eventId } = useParams();
  const [event, setEvent] = useState(null);
  const [sessions, setSessions] = useState([]);
  const [vendors, setVendors] = useState([]);

  // ---------- MODAL STATES ----------
  const [isAddSessionOpen, setIsAddSessionOpen] = useState(false);
  const [isAddSpeakerOpen, setIsAddSpeakerOpen] = useState(false);
  const [isAddTicketTypeOpen, setIsAddTicketTypeOpen] = useState(false);
  const [isAddVendorOpen, setIsAddVendorOpen] = useState(false);

  const [isEditOptionsOpen, setIsEditOptionsOpen] = useState(false);
  const [isEditEventOpen, setIsEditEventOpen] = useState(false);
  const [isEditVenueOpen, setIsEditVenueOpen] = useState(false);
  const [isEditTicketTypesOpen, setIsEditTicketTypesOpen] = useState(false);
  const [isEditSessionOptionsOpen, setIsEditSessionOptionsOpen] = useState(false);
  const [isEditSessionOpen, setIsEditSessionOpen] = useState(false);
  const [isEditSpeakerOpen, setIsEditSpeakerOpen] = useState(false);

  const [isSelectTicketTypeOpen, setIsSelectTicketTypeOpen] = useState(false);
  const [isSelectSessionOpen, setIsSelectSessionOpen] = useState(false);
  const [isCreateVendorOpen, setIsCreateVendorOpen] = useState(false);
  
  const [selectedTicketType, setSelectedTicketType] = useState(null);
  const [selectedSession, setSelectedSession] = useState(null);

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

  // ---------- FETCH EVENT SESSIONS ----------
  const fetchEventSessions = async () => {
    try {
      const data = await getSessionsForEvent(eventId, token);
      console.log("Fetched event sessions:", data.sessions);
      setSessions(data.sessions);
    } catch (err) {
      console.error("Error fetching event sessions:", err);
    }
  };

  // --- fetch event details on component mount ---
  useEffect(() => {
    fetchEvent();
    fetchEventSessions();
  }, [eventId, token]);

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

  // ---------- REGISTRATION RELATED USE EFFECTS ----------
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

  // --- dynamically display updated Event ---
  const handleUpdatedEvent = (updatedEvent) => {
    setEvent(updatedEvent);
  };

  const openAddVendorModal = async () => {
    try {
      const data = await fetchAllVendors(token);
      setVendors(data.vendors);
      setIsAddVendorOpen(true);
    } catch (err) {
      console.error("Error fetching vendors:", err);
    }
  };

  // ---------- HANDLE VENDOR SELECTION ----------
  const handleAddVendor = async (vendorId) => {
    await addVendorToEvent(eventId, vendorId, token);
    setIsAddVendorOpen(false);
    setIsCreateVendorOpen(true)
  };

  const handleCreateVendor = () => {
    setIsAddVendorOpen(false);
    setIsCreateVendorOpen(true);
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
      setIsSelectTicketTypeOpen(true);
    }
  };

  // ---------- HANDLE SESSION OPTIONS ----------
  const handleSessionOptions = (action) => {
    if (action === "editSession") {
      setIsEditSessionOptionsOpen(false);
      setIsEditSessionOpen(true);
    } else if (action === "editSpeaker") {
      setIsEditSessionOptionsOpen(false);
      setIsEditSpeakerOpen(true);
    }
  };

  // --------- HANDLE TICKET TYPE SELECTION ----------
  const handleTicketTypeSelect = (type) => {
    setSelectedTicketType(type);
    setIsSelectTicketTypeOpen(false);
    setIsEditTicketTypesOpen(true);
  };

  const handleCreateTicketType = () => {
    setIsSelectTicketTypeOpen(false);
    setIsAddTicketTypeOpen(true);
  };

  // ---------- HANDLE SESSION SELECTION ----------
  const handleSessionSelect = (session) => {
    setSelectedSession(session);
    setIsSelectSessionOpen(false);
    setIsAddSpeakerOpen(true);
  };

  const handleCreateSession = () => {
    setIsSelectSessionOpen(false);
    setIsAddSessionOpen(true);
  };

  // ---------- DELETE REGISTRATION ----------
  const handleDeleteRegistration = async (registrationId) => {
    try {
      await deleteRegistration(registrationId, token);
      alert("Registration has been deleted successfully!");

      // --- remove registration code to invalidate QR code ---
      setRegistrationCode(null);
    } catch (err) {
      alert('Failed to delete registration. Please try again.');
      console.error('Error deleting registration: ', err)
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

  // ---------- CONDITIONAL RENDERING ----------
  if (loading) return <div>Loading...</div>;
  if (!event) return <div>Event not found</div>;

  if (!token) {
    alert("You must be logged in to perform this action.");
    return;
  }

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
        <h2>{event.description}</h2>
      </header>

      <div className="moreEventDetailsBlock">
        {/* ---------- DISPLAY VENUE DETAILS ---------- */}
        {event.venue.name === "Virtual" ? (
          <div className="venueDetails">
            <h3>Venue: Virtual Event</h3>
          </div>
        ) : (
          <div className="venueDetails">
            <h3>Venue: {event.venue.name}</h3>
            <div className="venueLocation">
              <div className="addressBlock">
                <p>Address:</p>
                <p>{event.venue.address}{", "}</p>
                <p>{event.venue.city}, {event.venue.state}</p>
                <p>{event.venue.country}, {event.venue.zip_code}</p>
              </div>
            </div>
            <p>Venue Capacity: {event.venue.capacity ? `${event.venue.capacity} people` : 'N/A'}</p>
          </div>
        )}
        <div className="dateOrganizerCapacityBlock">
          <p>From: {formatDate(event.start_date)} - {formatDate(event.end_date)}</p>
          <p>Organizer: {event.organizer ? `${event.organizer.f_name} ${event.organizer.l_name}` : 'N/A'}</p>
          <p>Capacity: {event.capacity}</p>
        </div>
      </div>
      <button className="vendorBtn" onClick={openAddVendorModal}>
        <FontAwesomeIcon icon={faStore} /> Add Vendor
      </button>
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
          <button type="button" className="deleteBtn" onClick={() => handleDeleteRegistration(registration.id)}>
            Delete Registration
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

      {/* ---------- SESSION DETAILS ---------- */}
      <div className="SessionDetails">
        <hr />
        <h3>Event Schedule</h3>
        {/* --- Add Session Button for admin & organizers --- */}
        {user && (user.role_id === 1 || user.role_id === 4) && (
          <div className="sessionBtns">
            <button onClick={() => setIsAddSessionOpen(true)}>Add Event Session</button>
            <button onClick={() => setIsSelectSessionOpen(true)}>Add Speakers/ Performers</button>
          </div>
        )}
        {sessions && sessions.length === 0 ? (
          <p>No sessions available for this event.</p>
        ) : (
          <ul className="sessionList">
            {sessions.map((session) => (
              <li key={session.id} className="sessionListItem">
                <header>
                  <h4>{session.title}</h4>
                  {user && (user.role_id === 1 || user.role_id === 4) && (
                    <FontAwesomeIcon icon={faPenToSquare}
                      className="editIcon"
                      onClick={() => {
                        setSelectedSession(session);
                        setIsEditSessionOptionsOpen(true);
                      }}
                    />
                  )}
                </header>
                
                {session.speakers && session.speakers.length > 0 && (
                  <p>
                    <span>Speakers/ Performers:</span> {session.speakers.map(speaker => speaker.name).join(', ')}
                  </p>
                )}
                <p>{session.description}</p>
                <p>
                  From: {formatDate(session.start_time)} - To: {formatDate(session.end_time)}
                </p>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* ---------- ADD SESSION MODAL ---------- */}
      <Modal isOpen={isAddSessionOpen} onClose={() => setIsAddSessionOpen(false)}>
        <AddSession
          eventId={event.id}
          token={token}
          onClose={() => setIsAddSessionOpen(false)}
          onUpdate={fetchEventSessions}
        />
      </Modal>

      {/* ---------- SELECT SESSION MODAL ---------- */}
      <SelectSessionModal
        isOpen={isSelectSessionOpen}
        onClose={() => setIsSelectSessionOpen(false)}
        sessions={sessions || []}
        onSelect={handleSessionSelect}
        onCreate={handleCreateSession}
      />

      {/* ---------- ADD SPEAKER MODAL ---------- */}
      <Modal isOpen={isAddSpeakerOpen} onClose={() => setIsAddSpeakerOpen(false)}>
        {selectedSession && (
          <AddSpeaker
            userId={user?.id}
            sessionId={selectedSession.id}
            speakers={selectedSession.speakers}
            token={token}
            onClose={() => setIsAddSpeakerOpen(false)}
            onUpdate={fetchEventSessions}
          />
        )}
      </Modal>

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
          onEventUpdated={handleUpdatedEvent}
          event={event}
          token={token}
          onUpdate={fetchEvent}
          onClose={() => setIsEditEventOpen(false)}
        />
      </Modal>

      {/* ---------- EDIT VENUE MODAL ---------- */}
      <Modal isOpen={isEditVenueOpen} onClose={() => setIsEditVenueOpen(false)}>
        <EditVenue
          venueId={event.venue_id}
          venue={event.venue}
          token={token}
          onUpdate={fetchEvent}
          onClose={() => setIsEditVenueOpen(false)}
        />
      </Modal>

      {/* ---------- SELECT TICKET TYPE MODAL ---------- */}
      <SelectTicketTypeModal
        isOpen={isSelectTicketTypeOpen}
        onClose={() => setIsSelectTicketTypeOpen(false)}
        ticketTypes={event?.ticketTypes || []}
        onSelect={handleTicketTypeSelect}
        onCreate={handleCreateTicketType}
      />

      {/* ---------- EDIT TICKET TYPE MODAL ---------- */}
      <Modal isOpen={isEditTicketTypesOpen} onClose={() => setIsEditTicketTypesOpen(false)}>
        {selectedTicketType && (
          <EditTicketType
            eventId={eventId}
            ticketTypeId={selectedTicketType.id}
            ticketType={selectedTicketType}
            token={token}
            onUpdate={fetchEvent}
            onClose={() => setIsEditTicketTypesOpen(false)}
          />
        )}
      </Modal>

      {/* ---------- ADD TICKET TYPE MODAL ---------- */}
      <Modal isOpen={isAddTicketTypeOpen} onClose={() => setIsAddTicketTypeOpen(false)}>
        <AddTicketType
          eventId={eventId}
          token={token}
          onClose={() => setIsAddTicketTypeOpen(false)}
          onUpdate={fetchEvent}
        />
      </Modal>

      {/* ---------- SELECT VENDOR MODAL ---------- */}
      <DropDownModal
        isOpen={isAddVendorOpen}
        onClose={() => setIsAddVendorOpen(false)}
        vendors={vendors}
        onSelect={handleAddVendor}
        onCreate={handleCreateVendor}
      />

      {/* ---------- CREATE VENDOR MODAL ---------- */}
      <Modal isOpen={isCreateVendorOpen} onClose={() => setIsCreateVendorOpen(false)}>
        <AddVendor
          token={token}
          userId={user?.id}
          onClose={() => setIsCreateVendorOpen(false)}
          onUpdate={fetchEvent}
        />
      </Modal>

      {/* ---------- EDIT SESSION OPTIONS MODAL ---------- */}
      <OptionsModal
        isOpen={isEditSessionOptionsOpen}
        onClose={() => setIsEditSessionOptionsOpen(false)}
        title="What would you like to edit?"
        action1={() => handleSessionOptions("editSession")}
        action2={() => handleSessionOptions("editSpeaker")}
        option1="Edit Session"
        option2={"Edit Speaker"}
      />

      {/* ---------- EDIT SESSION MODAL ---------- */}
      <Modal isOpen={isEditSessionOpen} onClose={() => setIsEditSessionOpen(false)}>
        <EditSession
          session={selectedSession}
          token={token}
          onUpdate={fetchEventSessions}
          onClose={() => setIsEditSessionOpen(false)}
        />
      </Modal>

      {/* ---------- EDIT SPEAKER MODAL ---------- */}
      <Modal isOpen={isEditSpeakerOpen} onClose={() => setIsEditSpeakerOpen(false)}>
        {selectedSession && (
          <EditSpeaker
            speakers={selectedSession.speakers}
            sessionId={selectedSession.id}
            token={token}
            onUpdate={fetchEventSessions}
            onClose={() => setIsEditSpeakerOpen(false)}
          />
        )}
      </Modal>

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