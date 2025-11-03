import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/analytics`;
console.log('Event Metrics API URL:', API_URL);

// ---------- GET OPERATIONS ----------
// -------- FETCH EVENT METRICS --------
export const getEventMetrics = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/${eventId}/metrics`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH TICKET SALES METRICS --------
export const getTicketSales = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/${eventId}/ticket-sales`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH ATTENDEE ENGAGEMENT METRICS --------
export const getAttendence = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/${eventId}/attendee`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH REVENUE METRICS --------
export const getRevenue = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/${eventId}/revenue`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH NO-SHOW METRICS --------
export const getNoShow = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/${eventId}/no-show`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};