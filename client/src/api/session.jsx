import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/sessions`;
console.log("Session API URL:", API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE SESSION --------
export const createSession = async (sessionData, token) => {
  const res = await axios.post(API_URL, sessionData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- GET OPERATIONS ----------
// -------- GET SESSIONS FOR EVENT --------
export const getSessionsForEvent = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/event/${eventId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};