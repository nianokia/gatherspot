import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/auth`;
console.log('Auth API URL:', API_URL);

// ---------- DEFINE AUTH API CALLS ----------
export const registerUser = (data) => axios.post(`${API_URL}/register`, data);
export const loginUser = (data) => axios.post(`${API_URL}/login`, data);