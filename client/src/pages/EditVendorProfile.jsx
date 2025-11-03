import { useState, useEffect } from "react";
import { updateVendor, fetchAllVendors } from "../api/vendor.jsx";

const EditVendorProfile = ({ userId, token, loading, setLoading }) => {
  const [vendor, setVendor] = useState(null);
  const [formData, setFormData] = useState({
    company_name: "",
    contact_email: "",
    phone: ""
  });

  const fetchVendor = async () => {
    try {
      const data = await fetchAllVendors(token);
      const foundVendor = data.vendors.find(v => v.user_id === userId);
      // --- if vendor is found, set vendor & formData ---
      if (foundVendor) {
        setVendor(foundVendor);
        setFormData({
          company_name: foundVendor.company_name || "",
          contact_email: foundVendor.contact_email || "",
          phone: foundVendor.phone || ""
        });
      }
    } catch (err) {
      console.error("Error fetching vendor profile:", err);
    } finally {
      setLoading && setLoading(false);
    }
  };

  useEffect(() => {
    fetchVendor();
  }, [userId, token]);

  const handleChange = e => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!vendor) return;
    try {
      await updateVendor(vendor.id, formData, token);
      alert("Profile updated successfully!")

      console.log("Profile updated successfully", formData)
    } catch (err) {
      console.error("Error updating profile", err);
      alert("Error updating profile", err.message);
    }
  };

  // ----------- CONDITIONAL RENDERING -----------
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
