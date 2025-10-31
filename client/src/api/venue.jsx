import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/venues`;
console.log('Venue API URL:', API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE VENUE --------
export const createVenue = async (venueData, token) => {
  const res = await axios.post(`${API_URL}/create-venue`, venueData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};
