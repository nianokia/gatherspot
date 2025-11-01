import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/events`;
console.log('Event API URL:', API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE EVENT --------
export const createEvent = async (eventData, token) => {
  const res = await axios.post(`${API_URL}/create-event`, eventData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- GET OPERATIONS ----------
// -------- FETCH ALL EVENTS --------
export const fetchEvents = async (token) => {
  const res = await axios.get(API_URL, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH EVENT BY ID --------
export const fetchEventById = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/${eventId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH EVENTS BY ORGANIZER --------
export const fetchEventsByOrganizer = async (organizerId, token) => {
  const res = await axios.get(`${API_URL}/organizer/${organizerId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH EVENTS BY VENUE --------
export const fetchEventsByVenue = async (venueId, token) => {
  const res = await axios.get(`${API_URL}/venue/${venueId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- DELETE OPERATIONS ----------
// -------- DELETE EVENT --------
export const deleteEvent = async (eventId, token) => {
  const res = await axios.delete(`${API_URL}/${eventId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};