import { useState } from 'react';
import { updateEvent } from '../api/event.jsx';

const EditEvent = ({ eventId, setIsModalOpen, onEventUpdated, event, ticketTypes, venue, token, onClose, onUpdate }) => {
  const [formData, setFormData] = useState({
    title: event.title,
    event_type: event.event_type,
    description: event.description,
    start_date: event.start_date,
    end_date: event.end_date,
    capacity: event.capacity,
    waitlist_enabled: event.waitlist_enabled,
    status: event.status
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  // --------- HANDLE FORM SUBMISSION ----------
  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      await updateEvent(event.id, formData, token);
      // --- Refresh event details ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error('Update Event Error:', err);
      // if (err.response && err.response.data && err.response.data.message) {
      //   setError(err.response.data.message);
      // } else {
      //   setError('Failed to update event. Please try again.');
      // }
    }
  };

  return (
    <div className="EditEvent">
      <h2>Edit Event</h2>
      <form onSubmit={handleSubmit}>
        <div className="formGroup">
          <label>Title:</label>
          <input type="text" name="title" value={formData.title} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label>Description:</label>
          <textarea name="description" value={formData.description} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label>Start Date:</label>
          <input type="datetime-local" name="start_date" value={formData.start_date} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label>End Date:</label>
          <input type="datetime-local" name="end_date" value={formData.end_date} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label>Capacity:</label>
          <input type="number" name="capacity" value={formData.capacity} onChange={handleChange} min="1" required />
        </div>
        <div className="formGroup">
          <label>Waitlist Enabled:</label>
          <input type="checkbox" name="waitlist_enabled" checked={formData.waitlist_enabled} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label>Status:</label>
            <select name="status" value={formData.status} onChange={handleChange}>
              <option value="scheduled">Scheduled</option>
              <option value="completed">Completed</option>
              <option value="canceled">Canceled</option>
            </select>
        </div>

        <button type="submit">Save Changes</button>
        <button type="button" onClick={onClose}>Cancel</button>
      </form>
    </div>
  );
};

export default EditEvent;