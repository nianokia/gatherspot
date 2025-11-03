import { useState } from "react";
import { updateVenue } from "../api/venue.jsx";

const EditVenue = ({ venueId, venue, token, onUpdate, onClose }) => {
  const [formData, setFormData] = useState({
    name: venue?.name || '',
    address: venue?.address || '',
    city: venue?.city || '',
    state: venue?.state || '',
    country: venue?.country || '',
    zip_code: venue?.zip_code || '',
    capacity: venue?.capacity || 'null'
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
      await updateVenue(venueId, formData, token);
      alert('Venue has been updated!');
      // --- Refresh parent component data ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error('Update Venue Error:', err);
      alert('Error updating venue: ' + (err?.response?.data?.message || err.message));
    }
  };

  return (
    <div className="EditVenue">
      <h2>Edit Venue</h2>
      <form className='EditVenueForm' onSubmit={handleSubmit}>
        <div className="formGroup">
          <label htmlFor="name">Name:</label>
          <input type="text" id="name" name="name" placeholder="Name"
            value={formData.name} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="address">Address:</label>
          <input type="text" id="address" name="address" placeholder="Address"
            value={formData.address} onChange={handleChange} required/>
        </div>
        <div className="formGroup">
          <label htmlFor="city">City:</label>
          <input type="text" id="city" name="city" placeholder="City"
            value={formData.city} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label htmlFor="state">State:</label>
          <input type="text" id="state" name="state" placeholder="State"
            value={formData.state} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label htmlFor="country">Country:</label>
          <input type="text" id="country" name="country" placeholder="Country"
            value={formData.country} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label htmlFor="zip_code">Zip Code:</label>
          <input type="text" id="zip_code" name="zip_code" placeholder="Zip Code"
            value={formData.zip_code} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label htmlFor="capacity">Capacity:</label>
          <input type="number" id="capacity" name="capacity" min="1" placeholder="Capacity"
            value={formData.capacity} onChange={handleChange} />
        </div>
        <button type="submit">Update Venue</button>
      </form>
    </div>
  );
};

export default EditVenue;