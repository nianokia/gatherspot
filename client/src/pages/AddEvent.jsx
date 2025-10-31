import { BackButton } from '../constants/constant.jsx';

const AddEvent = () => {
  return (
    <div className="AddEvent">
      <BackButton />
      <h1>Add Event Page</h1>
      <form className='AddEventForm'>
        {/* ---------- EVENT DETAILS ---------- */}
        <div className="formGroup">
          <label htmlFor="title">Title</label>
          <input type="text" id="title" name="title" required placeholder="Event Title" />
        </div>
        <div className="formGroup">
          <label htmlFor="event_type">Type of Event</label>
          <input type="text" id="event_type" name="event_type" required placeholder="Event Type" />
        </div>
        <div className="formGroup">
          <label htmlFor="description">Description</label>
          <textarea id="description" name="description" placeholder="Description" />
        </div>

        {/* ---------- VENUE INFORMATION ---------- */}
        <div className="venueGroup">
          <div className="formGroup">
            <label htmlFor="name">Venue Name:</label>
            <input type="text" id="name" name="name" required placeholder="Name" />
          </div>
          <div className="formGroup">
            <label htmlFor="address">Address:</label>
            <input type="text" id="address" name="address" required placeholder="Address" />
          </div>
          <div className="formGroup">
            <label htmlFor="city">City:</label>
            <input type="text" id="city" name="city" required placeholder="City" />
          </div>
          <div className="formGroup">
            <label htmlFor="state">State:</label>
            <input type="text" id="state" name="state" required placeholder="State" />
          </div>
          <div className="formGroup">
            <label htmlFor="country">Country:</label>
            <input type="text" id="country" name="country" required placeholder="Country" />
          </div>
          <div className="formGroup">
            <label htmlFor="zip_code">Zip Code:</label>
            <input type="text" id="zip_code" name="zip_code" placeholder="Zip Code" />
          </div>
          <div className="formGroup">
            <label htmlFor="venue_capacity">Venue Capacity:</label>
            <input type="number" id="venue_capacity" name="venue_capacity" min="1" placeholder="Venue Capacity" />
          </div>
        </div>

        {/* ---------- EVENT DETAILS (cont) ---------- */}
        <div className="formGroup">
          <label htmlFor="start_date">Start Date</label>
          <input type="date" id="start_date" name="start_date" required />
        </div>
        <div className="formGroup">
          <label htmlFor="end_date">End Date</label>
          <input type="date" id="end_date" name="end_date" required />
        </div>
        <div className="formGroup">
          <label htmlFor="capacity">Capacity</label>
          <input type="number" id="capacity" name="capacity" min="1" required placeholder="Capacity" />
        </div>
        <div className="formGroup">
          <label htmlFor="waitlist_enabled">Enable Waitlist</label>
          <input type="checkbox" id="waitlist_enabled" name="waitlist_enabled" />
        </div>
        
        <button type="submit" className="createBtn">Create Event</button>
      </form>
    </div>
  );
};

export default AddEvent;