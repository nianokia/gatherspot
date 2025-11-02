import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/venues`;
console.log('Venue API URL:', API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE VENUE --------
export const createVenue = async (venueData, token) => {
  const res = await axios.post(`${API_URL}/create`, venueData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- PUT OPERATIONS ----------
// -------- UPDATE VENUE --------
export const updateVenue = async (venueId, updatedData, token) => {
  const res = await axios.put(`${API_URL}/update/${venueId}`, updatedData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
}