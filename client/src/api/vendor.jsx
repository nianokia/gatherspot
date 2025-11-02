import axios from "axios";

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/vendors`;
console.log("Vendor API URL:", API_URL);

// ---------- CREATE OPERATIONS ----------
// -------- CREATE VENDOR --------
export const createVendor = async (vendorData, token) => {
  const res = await axios.post(API_URL, vendorData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- GET OPERATIONS ----------
// -------- FETCH ALL VENDORS --------
export const fetchAllVendors = async (token) => {
  const res = await axios.get(API_URL, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH EVENTS BY VENDOR ID --------
export const fetchEventsByVendorId = async (vendorId, token) => {
  const res = await axios.get(`${API_URL}/${vendorId}/events`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- UPDATE OPERATIONS ----------
// -------- UPDATE VENDOR --------
export const updateVendor = async (vendorId, vendorData, token) => {
  const res = await axios.put(`${API_URL}/${vendorId}`, vendorData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- DELETE OPERATIONS ----------
// -------- DELETE VENDOR --------
export const deleteVendor = async (vendorId, token) => {
  const res = await axios.delete(`${API_URL}/${vendorId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};