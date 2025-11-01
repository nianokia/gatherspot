import axios from "axios";

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/waitlist`;
console.log("Waitlist API URL:", API_URL);

// ---------- POST OPERATIONS ----------
// -------- ADD TO WAITLIST --------
export const addToWaitlist = async (waitlistData, token) => {
  const res = await axios.post(`${API_URL}/add`, waitlistData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};