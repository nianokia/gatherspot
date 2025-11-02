import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/ticket-types`;
console.log('Ticket Type API URL:', API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE TICKET TYPE --------
export const createTicketType = async (ticketTypeData, token) => {
  const res = await axios.post(`${API_URL}/create`, ticketTypeData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- PUT OPERATIONS ----------
// -------- UPDATE TICKET TYPE --------
export const updateTicketType = async (ticketTypeId, updatedData, token) => {
  const res = await axios.put(`${API_URL}/update/${ticketTypeId}`, updatedData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};