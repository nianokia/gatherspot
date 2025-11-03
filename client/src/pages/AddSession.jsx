import { useState } from "react";
import { createSession } from "../api/session.jsx";

const AddSession = ({ eventId, token, onClose, onUpdate }) => {
  const [formData, setFormData] = useState({
    eventId: eventId,
    title: '', 
    description: '', 
    start_time: '', 
    end_time: '', 
    venue_location: ''
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    // --- set changing input while retaining other fields ---
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // --------- HANDLE FORM SUBMISSION ----------
  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      // ---------- CREATE SESSION ----------
      const response = await createSession(formData, token);
      if (!response) throw new Error("Failed to create session");
      
      console.log("createSession response:", response);
      alert("Session has been created!");

      // --- Refresh event details ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error("Error creating session:", err);
      alert("Error creating session. Make sure the End Date/ Time is after the Start Date/ Time.\n Error: " + (err?.response?.data?.message || err.message));
    }
  };

  return (
    <div>
      <h1>Add Session Page</h1>
      <form className='AddVenueForm' onSubmit={handleSubmit}>
        <div className="formGroup">
          <label htmlFor="title" className="required">Title:</label>
          <input type="text" id="title" name="title" placeholder="Title"
            value={formData.title} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="description">Description:</label>
          <input type="text" id="description" name="description" placeholder="Description"
            value={formData.description} onChange={handleChange}/>
        </div>
        <div className="formGroup">
          <label htmlFor="venue_location">Venue Location:</label>
          <input type="text" id="venue_location" name="venue_location" placeholder="Venue Location"
            value={formData.venue_location} onChange={handleChange}/>
        </div>
        <div className="formGroup">
          <label htmlFor="start_time" className="required">Start Date/ Time</label>
          <input type="datetime-local" id="start_time" name="start_time"
            value={formData.start_time} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="end_time" className="required">End Date/ Time</label>
          <input type="datetime-local" id="end_time" name="end_time"
            value={formData.end_time} onChange={handleChange} required/>
        </div>
        <div>
          <button type="submit" className="createBtn">Create Session</button>
        </div>
      </form>
    </div>
  );
};

export default AddSession;