import { useState, useEffect } from 'react';
import { getAllEventTicketTypes, updateTicketType } from '../api/ticketType.jsx';

const EditTicketType = ({ eventId, ticketTypeId, ticketType, setIsModalOpen, onEventUpdated, token, onClose, onUpdate }) => {
  const [ticketTypes, setTicketTypes] = useState([]);
  const [formData, setFormData] = useState({
    name: ticketType?.name || '',
    price: ticketType?.price || '',
    quantity: ticketType?.quantity || '',
    sale_start: ticketType?.sale_start || '',
    sale_end: ticketType?.sale_end || ''
  });

  // ---------- FETCH EVENT'S TICKET TYPES ----------
  const fetchEventTicketTypes = async () => {
    try {
      const data = await getAllEventTicketTypes(eventId, token);
      console.log("Fetched ticket types for event:", data);

      // --- ticketTypes array is located in data.ticketTypes ---
      setTicketTypes(data.ticketTypes);
    } catch (error) {
      console.error("Error fetching Event's ticket types:", error);
    }
  };

  // --- fetch ticket types on component mount ---
  useEffect(() => {
    if (eventId) {
      fetchEventTicketTypes();
    }
  }, [eventId]);

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
      await updateTicketType(ticketTypeId, formData, token);
      // --- Refresh event details ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error('Update Ticket Type Error:', err);
      // if (err.response && err.response.data && err.response.data.message) {
      //   setError(err.response.data.message);
      // } else {
      //   setError('Failed to update ticket type. Please try again.');
      // }
    }
  };

  console.log("Ticket Types: ", ticketTypes);

  return (
    <div className="EditTicketType">
      <h1>Edit Ticket Type Form</h1>
      <div key={ticketTypeId} className="ticketTypeItem">
        <h3>{ticketType.name}</h3>
        <span>Price: {ticketType.price}, </span>
        <span>Quantity: {ticketType.quantity}, </span>
        <br />
        {ticketType.sale_start === null ? (
          <span>Sale Start: N/A, </span>
        ) : (
          <span>Sale Start: {ticketType.sale_start}, </span>
        )}
        {ticketType.sale_end === null ? (
          <span>Sale End: N/A</span>
        ) : (
          <span>Sale End: {ticketType.sale_end}</span>
        )}
      </div>

      {/* ---------- EDIT TICKET TYPE FORM ---------- */}
      <form className='EditTicketTypeForm' onSubmit={handleSubmit}>
        <div className="formGroup">
          <label htmlFor="name">Name:</label>
          <input type="text" id="name" name="name" placeholder="Name"
            value={formData.name} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="price">Price:</label>
          <input type="text" id="price" name="price" placeholder="Price"
            value={formData.price} onChange={handleChange} required/>
        </div>
        <div className="formGroup">
          <label htmlFor="quantity">Quantity:</label>
          <input type="text" id="quantity" name="quantity" min="1" placeholder="Quantity"
            value={formData.quantity} onChange={handleChange} required/>
        </div>
        <div className="formGroup">
          <label htmlFor="sale_start">Start Date</label>
          <input type="datetime-local" id="sale_start" name="sale_start"
            value={formData.sale_start} onChange={handleChange} />
        </div>
        <div className="formGroup">
          <label htmlFor="sale_end">End Date</label>
          <input type="datetime-local" id="sale_end" name="sale_end"
            value={formData.sale_end} onChange={handleChange} />
        </div>
        
        {/* ---------- FORM BUTTONS ---------- */}
        <div className="formButtons">
          <button type="submit" className="createBtn">Edit Ticket Type</button>
          <button type='button' onClick={onClose} className='dashboardBtn'>Back to Event Details</button>
        </div>
      </form>
    </div>
  );
};

export default EditTicketType;