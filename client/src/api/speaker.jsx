import axios from 'axios';

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/speakers`;
console.log("Speaker API_URL:", API_URL);

// ------------ POST OPERATIONS ------------
// ---------- CREATE SPEAKER ----------
export const createSpeaker = async (speakerData, token) => {
  const res = await axios.post(API_URL, speakerData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};