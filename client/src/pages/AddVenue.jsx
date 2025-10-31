import { useState, useContext } from 'react';
import { useNavigate } from 'react-router';
import AuthContext from '../context/authContext.jsx';
import { createVenue } from '../api/venue.jsx';
import { BackButton } from '../constants/constant.jsx';

const AddVenue = () => {
  const navigate = useNavigate();
  const { token } = useContext(AuthContext);
  // ---------- FORM DATA STATE ----------
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    city: '',
    state: '',
    country: '',
    zip_code: '',
    capacity: ''
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    // --- set changing input while retaining other fields ---
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    console.log("Submitting AddVenue form: \n token:", token);
    console.log("Submitting AddVenue form: \n formData:", formData);

    try {
      const response = await createVenue(formData, token);
      if (!response) throw new Error("Failed to create venue");
      console.log("createVenue response:", response);
      alert("Venue has been added!")

      // --- navigate back to previous page ---
      navigate(-1);
    } catch (err) {
      console.error("Error creating venue: ", err?.response ?? err);
      alert("Error creating venue: " + (err?.response?.data?.message || err.message));
    }
  };

  console.log("Form Data: ", formData);

  return (
    <div className="AddVenue">
      <BackButton />
      <h1>Add Venue Page</h1>
      <form className='AddVenueForm' onSubmit={handleSubmit}>
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
            value={formData.city} onChange={handleChange} required/>
        </div>
        <div className="formGroup">
          <label htmlFor="state">State:</label>
          <input type="text" id="state" name="state" placeholder="State"
            value={formData.state} onChange={handleChange} required/>
        </div>
        <div className="formGroup">
          <label htmlFor="country">Country:</label>
          <input type="text" id="country" name="country" placeholder="Country"
            value={formData.country} onChange={handleChange} required/>
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
        <div>
          <button type="submit" className="createBtn">Create Venue</button>
        </div>
      </form>
    </div>
  );
};

export default AddVenue;