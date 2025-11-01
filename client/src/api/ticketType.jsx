import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/ticket-types`;
console.log('Ticket Type API URL:', API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE TICKET TYPE --------
export const createTicketType = async (ticketTypeData, token) => {
  const res = await axios.post(`${API_URL}/create-ticket-type`, ticketTypeData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};