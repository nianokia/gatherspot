import { useState, useContext } from 'react';
import { useNavigate, useParams } from 'react-router';
import AuthContext from '../context/authContext.jsx';
import { createTicketType } from '../api/ticketType.jsx';
import { BackButton } from '../constants/constant.jsx';

const AddTicketType = () => {
  const navigate = useNavigate();
  const { eventId } = useParams();
  const { user, token } = useContext(AuthContext);
  // ---------- FORM DATA STATE ----------
  const [formData, setFormData] = useState({
    event_id: eventId,
    name: '',
    price: '',
    quantity: '',
    sale_start: '',
    sale_end: ''
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    // --- set changing input while retaining other fields ---
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    console.log("Submitting AddTicketType form: \n token:", token);
    console.log("Submitting AddTicketType form: \n formData:", formData);

    try {
      const response = await createTicketType(formData, token);
      if (!response) throw new Error("Failed to create ticket type");
      console.log("createTicketType response:", response);
      alert("Ticket type has been added!");

    } catch (err) {
      console.error("Error creating ticket type: ", err?.response ?? err);
      alert("Error creating ticket type: " + (err?.response?.data?.message || err.message));
    }
  };

  // --- navigate back to respective dashboard ---
  const navigateToDashboard = () => {
    navigate(user?.role_id === 1 ? '/organizer' 
    : user?.role_id === 2 ? '/attendee'
    : user?.role_id === 3 ? '/vendor'
    : user?.role_id === 4 ? '/admin'
    : '/'
    );
  };

  console.log("Form Data: ", formData);

  return (
    <div className="AddTicketType">
      <BackButton />
      <h1>Add Ticket Type Page</h1>
      <form className='AddTicketTypeForm' onSubmit={handleSubmit}>
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
        
        <div className="formButtons">
          <button type="submit" className="createBtn">Create Ticket Type</button>
          <button type="button" className="dashboardBtn" onClick={navigateToDashboard}>Go to Dashboard</button>
        </div>
      </form>
    </div>
  );
};

export default AddTicketType;