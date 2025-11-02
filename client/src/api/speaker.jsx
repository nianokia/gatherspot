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

// ------------ GET OPERATIONS ------------
// ---------- GET SPEAKER BY ID ----------
export const getSpeakerById = async (speakerId, token) => {
  const res = await axios.get(`${API_URL}/${speakerId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ------------ PUT OPERATIONS ------------
// ---------- UPDATE SPEAKER ----------
export const updateSpeaker = async (speakerId, speakerData, token) => {
  const res = await axios.put(`${API_URL}/${speakerId}`, speakerData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ------------ DELETE OPERATIONS ------------
// ---------- DELETE SPEAKER ----------
export const deleteSpeaker = async (speakerId, token) => {
  const res = await axios.delete(`${API_URL}/${speakerId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};