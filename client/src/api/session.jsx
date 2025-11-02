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

// -------- ADD SPEAKERS TO SESSION --------
export const addSpeakersToSession = async (sessionId, speakerIds, token) => {
  const res = await axios.post(
    `${API_URL}/${sessionId}/speakers`,
    { speakerIds },
    { headers: { Authorization: `Bearer ${token}` } }
  );
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

// ---------- PUT OPERATIONS ----------
// -------- UPDATE SESSION --------
export const updateSession = async (sessionId, updatedData, token) => {
  const res = await axios.put(
    `${API_URL}/${sessionId}`,
    updatedData,
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return res.data;
};

// ---------- DELETE OPERATIONS ----------
// -------- DELETE SESSION --------
export const deleteSession = async (sessionId, token) => {
  const res = await axios.delete(
    `${API_URL}/${sessionId}`,
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return res.data;
};

// -------- REMOVE SPEAKER FROM SESSION --------
export const removeSpeakerFromSession = async (sessionId, speakerId, token) => {
  const res = await axios.delete(
    `${API_URL}/${sessionId}/speakers/${speakerId}`,
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return res.data;
};