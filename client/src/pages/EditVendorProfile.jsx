import { useState, useEffect } from "react";
import { updateVendor, fetchAllVendors } from "../api/vendor.jsx";

const EditVendorProfile = ({ userId, token }) => {
  const [vendor, setVendor] = useState(null);
  const [formData, setFormData] = useState({
    company_name: "",
    contact_email: "",
    phone: ""
  });
  const [loading, setLoading] = useState(true);

  // ---------- FETCH VENDOR PROFILE ----------
  const fetchVendor = async () => {
    try {
      const data = await fetchAllVendors(token);
      // Find vendor with matching user_id
      const found = data.vendors.find(v => v.user_id === userId);
      if (found) {
        setVendor(found);
        setFormData({
          company_name: found.company_name || "",
          contact_email: found.contact_email || "",
          phone: found.phone || ""
        });
      }
    } catch (err) {
      setMessage("Error fetching vendor profile");
    } finally {
      setLoading(false);
    }
  };

  // --- Fetch vendor profile by userId ---
  useEffect(() => {
    fetchVendor();
  }, [userId, token]);

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = e => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  // ---------- HANDLE SUBMISSION ----------
  const handleSubmit = async e => {
    e.preventDefault();
    if (!vendor) return;
    try {
      await updateVendor(vendor.id, formData, token);
      setMessage("Profile updated successfully!");
    } catch (err) {
      setMessage("Error updating profile");
    }
  };

  // ---------- CONDITIONAL RENDERING ----------
  if (loading) return <div>Loading vendor profile...</div>;
  if (!vendor) return <div>No vendor profile found.</div>;

  return (
    <div className="EditVendorProfile">
      <h2>Edit Vendor Profile</h2>
      <form onSubmit={handleSubmit}>
        <div className="formGroup">
          <label htmlFor="company_name">Company Name:</label>
          <input type="text" id="company_name" name="company_name"
            value={formData.company_name} onChange={handleChange}
          />
        </div>
        <div className="formGroup">
          <label htmlFor="contact_email">Contact Email:</label>
          <input type="email" id="contact_email" name="contact_email"
            value={formData.contact_email} onChange={handleChange}
          />
        </div>
        <div className="formGroup">
          <label htmlFor="phone">Phone:</label>
          <input type="tel" id="phone" name="phone"
            value={formData.phone} onChange={handleChange}
          />
        </div>
        <button type="submit" className="createBtn">Update Profile</button>
      </form>
    </div>
  );
};

export default EditVendorProfile;
