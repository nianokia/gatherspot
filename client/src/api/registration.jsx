import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/registrations`;
console.log('Registration API URL:', API_URL);

// ---------- POST OPERATIONS ----------
// -------- CREATE REGISTRATION --------
export const createRegistration = async (registrationData, token) => {
  const res = await axios.post(`${API_URL}/register`, registrationData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- GET OPERATIONS ----------
// -------- FETCH REGISTRATIONS BY USER ID --------
export const fetchRegistrationsByUser = async (userId, token) => {
  const res = await axios.get(`${API_URL}/user/${userId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};