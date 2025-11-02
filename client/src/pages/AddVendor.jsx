import { useState } from "react";
import { createVendor } from "../api/vendor.jsx";

const AddVendor = ({ onSuccess, onUpdate, userId, token }) => {
  const [formData, setFormData] = useState({
    user_id: userId,
    company_name: '',
    email: '',
    phone: ''
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    // --- set changing input while retaining other fields ---
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    console.log("Submitting AddVendor form: \n formData:", formData);

    try {
      const response = await createVendor(formData, token);
      if (!response) throw new Error("Failed to create vendor");
      console.log("createVendor response:", response);
      alert("Vendor has been added!")

      // --- refresh event details to show new vendor ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error("Error creating vendor: ", err?.response ?? err);
      alert("Error creating vendor: " + (err?.response?.data?.message || err.message));
    }
  };

  console.log("Form Data: ", formData);
  return (
    <div className="AddVendor">
      <form className="AddVendorForm" onSubmit={handleSubmit}>
        <h2>Add Vendor Page</h2>
          <div className="formGroup">
            <label htmlFor="company_name">Company Name:</label>
            <input type="text" id="company_name" name="company_name" placeholder="Company Name"
              value={formData.company_name} onChange={handleChange} required />
          </div>
          <div className="formGroup">
            <label htmlFor="email">Email:</label>
            <input type="email" id="email" name="email" placeholder="Email"
              value={formData.email} onChange={handleChange} required/>
          </div>
          <div className="formGroup">
            <label htmlFor="phone">Phone Number:</label>
            <input type="tel" id="phone" name="phone" placeholder="Phone Number"
              value={formData.phone} onChange={handleChange} required/>
          </div>
        <button type="submit" className="createBtn">Create Vendor</button>
      </form>
    </div>
  );
};

export default AddVendor;