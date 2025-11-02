
import { useState } from "react";
import { Modal } from "../../constants/constant";

const DropDownModal = ({ isOpen, onClose, vendors, onSelect, onCreate }) => {
  const [selectedVendorId, setSelectedVendorId] = useState("");
  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (selectedVendorId) onSelect(selectedVendorId);
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <h2>Add a Vendor to Event</h2>
      <div className="selectVendorContainer">
        {vendors.length === 0 ? (
          <>
            <p>No vendors available.</p>
            <button className="createBtn" onClick={onCreate}>Create Vendor</button>
          </>
        ) : (
          <>
            <form onSubmit={handleSubmit} className="AddVendorForm">
              {/* ---------- VENDOR DROPDOWN ---------- */}
              <select
                className="sessionBtnGroup vendorDropdown"
                value={selectedVendorId}
                onChange={(e) => setSelectedVendorId(e.target.value)}
              >
                <option value="" disabled>Select a vendor</option>
                {vendors.map((vendor) => (
                  <option key={vendor.id} className="sessionBtn" value={vendor.id}>
                    {vendor.company_name}
                  </option>
                ))}
              </select>
              {/* --- disable add vendor button if no vendor is selected --- */}
              <button type="submit" className="vendorBtn" disabled={!selectedVendorId}>
                Add Vendor
              </button>
            </form>
            <div className="notYourVendorSection">
              <span>Don't see your vendor?</span>
              <button className="createBtn" onClick={onCreate}>
                Create New Vendor
              </button>
            </div>
          </>
        )}
      </div>
    </Modal>
  );
};

export default DropDownModal;
