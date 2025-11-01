import { useState, useContext } from 'react';
import { useNavigate } from 'react-router';
import AuthContext from '../context/authContext.jsx';
import { createEvent } from '../api/event.jsx';
import { BackButton } from '../constants/constant.jsx';

const AddEvent = () => {
  const navigate = useNavigate();
  const { user, token } = useContext(AuthContext);
  // ---------- FORM DATA STATE ----------
  // --- set 2 nested objects (eventDetails & venueDetails) coming from transaction ---
  const [formData, setFormData] = useState({
    eventDetails: {
      organizer_id: user?.id,
      title: '',
      event_type: '',
      description: '',
      start_date: '',
      end_date: '',
      capacity: '',
      waitlist_enabled: false,
      status: 'scheduled'
    },
    venueDetails: {
      name: '',
      address: '',
      city: '',
      state: '',
      country: '',
      zip_code: '',
      capacity: ''
    }
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    
    // --- set nested form data based on input name ---
    if (name.startsWith('venueDetails.')) {
      // --- attain the field name after the dot ---
      const field = name.split('.')[1];

      // --- set changed input in venueDetails while retaining other fields ---
      setFormData((prev) => ({
        ...prev,
        venueDetails: {
          ...prev.venueDetails,
          [field]: value
        }
      }));
      return;
    } else if (name.startsWith('eventDetails.')) {
      const field = name.split('.')[1];

      // --- set changed input in eventDetails while retaining other fields ---
      setFormData((prev) => ({
        ...prev,
        eventDetails: {
          ...prev.eventDetails,
          [field]: name === 'eventDetails.waitlist_enabled' ? e.target.checked : value
        }
      }));
      return;
    } else {
      // --- set changed input while retaining other fields ---
      setFormData((prev) => ({ ...prev, [name]: value }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    console.log("Submitting AddEvent form: \n token:", token);
    console.log("Submitting AddEvent form: \n formData:", formData);

    // --- convert capacity fields to numbers ---
    const eventDetailsWithCapacity = {
      ...formData.eventDetails,
      capacity: Number(formData.eventDetails.capacity)
    };
    const venueDetailsWithCapacity = {
      ...formData.venueDetails,
      capacity: Number(formData.venueDetails.capacity)
    };

    try {
      const response = await createEvent(formData, token);
      if (!response) throw new Error("Failed to create event");
      console.log("createEvent response:", response);
      alert("Event has been added!")

      // --- navigate back to previous page ---
      navigate(`/add-ticket-type/${response.event.id}`);
    } catch (err) {
      console.error("Error creating event: ", err?.response ?? err);
      alert("Error creating event: " + (err?.response?.data?.message || err.message));
    }
  };

  console.log("Form Data: ", formData);

  return (
    <div className="AddEvent">
      <BackButton />
      <h1>Add Event Page</h1>
      <form className='AddEventForm' onSubmit={handleSubmit}>
        {/* ---------- EVENT DETAILS ---------- */}
        <div className="formGroup">
          <label htmlFor="eventDetails.title">Title</label>
          <input type="text" id="eventDetails.title" name="eventDetails.title" placeholder="Event Title"
            value={formData.eventDetails.title} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="eventDetails.event_type">Type of Event</label>
          <input type="text" id="eventDetails.event_type" name="eventDetails.event_type" placeholder="Event Type"
            value={formData.eventDetails.event_type} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="eventDetails.description">Description</label>
          <textarea id="eventDetails.description" name="eventDetails.description" placeholder="Description"
            value={formData.eventDetails.description} onChange={handleChange} />
        </div>

        {/* ---------- VENUE INFORMATION ---------- */}
        <div className="venueGroup">
          <div className="formGroup">
            <label htmlFor="venueDetails.name">Venue Name:</label>
            <input type="text" id="venueDetails.name" name="venueDetails.name"  placeholder="Name"
              value={formData.venueDetails.name} onChange={handleChange} required />
          </div>
          <div className="formGroup">
            <label htmlFor="venueDetails.address">Address:</label>
            <input type="text" id="venueDetails.address" name="venueDetails.address" placeholder="Address"
              value={formData.venueDetails.address} onChange={handleChange} required />
          </div>
          <div className="formGroup">
            <label htmlFor="venueDetails.city">City:</label>
            <input type="text" id="venueDetails.city" name="venueDetails.city" placeholder="City"
              value={formData.venueDetails.city} onChange={handleChange} />
          </div>
          <div className="formGroup">
            <label htmlFor="venueDetails.state">State:</label>
            <input type="text" id="venueDetails.state" name="venueDetails.state" placeholder="State"
              value={formData.venueDetails.state} onChange={handleChange} />
          </div>
          <div className="formGroup">
            <label htmlFor="venueDetails.country">Country:</label>
            <input type="text" id="venueDetails.country" name="venueDetails.country" placeholder="Country"
              value={formData.venueDetails.country} onChange={handleChange} />
          </div>
          <div className="formGroup">
            <label htmlFor="venueDetails.zip_code">Zip Code:</label>
            <input type="text" id="venueDetails.zip_code" name="venueDetails.zip_code" placeholder="Zip Code"
              value={formData.venueDetails.zip_code} onChange={handleChange} />
          </div>
          <div className="formGroup">
            <label htmlFor="venueDetails.capacity">Venue Capacity:</label>
            <input type="number" id="venueDetails.capacity" name="venueDetails.capacity" placeholder="Venue Capacity"
              value={formData.venueDetails.capacity} onChange={handleChange} min="1" />
          </div>
        </div>

        {/* ---------- EVENT DETAILS (cont) ---------- */}
        <div className="formGroup">
          <label htmlFor="eventDetails.start_date">Start Date</label>
          <input type="datetime-local" id="eventDetails.start_date" name="eventDetails.start_date"
            value={formData.eventDetails.start_date} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="eventDetails.end_date">End Date</label>
          <input type="datetime-local" id="eventDetails.end_date" name="eventDetails.end_date"
            value={formData.eventDetails.end_date} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="eventDetails.capacity">Capacity</label>
          <input type="number" id="eventDetails.capacity" name="eventDetails.capacity" placeholder="Capacity"
            value={formData.eventDetails.capacity} onChange={handleChange} min="1" required />
        </div>
        <div className="formGroup">
          <label htmlFor="eventDetails.waitlist_enabled">Enable Waitlist</label>
          <input type="checkbox" id="eventDetails.waitlist_enabled" name="eventDetails.waitlist_enabled"
            checked={formData.eventDetails.waitlist_enabled} onChange={handleChange} />
        </div>
        
        <button type="submit" className="createBtn">Create Event</button>
      </form>
    </div>
  );
};

export default AddEvent;