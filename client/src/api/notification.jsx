import axios from "axios";

const API_URL = `${import.meta.env.VITE_DOMAIN}/api/notifications`;
console.log("Notification API URL:", API_URL);

// ---------- CREATE OPERATIONS ----------
// -------- CREATE NOTIFICATION --------
export const createNotification = async (notificationData, token) => {
  const res = await axios.post(API_URL, notificationData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- GET OPERATIONS ----------
// -------- FETCH ALL NOTIFICATIONS --------
export const fetchAllNotifications = async (token) => {
  const res = await axios.get(API_URL, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// -------- FETCH NOTIFICATIONS BY EVENT ID --------
export const fetchNotificationsByEventId = async (eventId, token) => {
  const res = await axios.get(`${API_URL}/event/${eventId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- UPDATE OPERATIONS ----------
// -------- UPDATE NOTIFICATION --------
export const updateNotification = async (notificationId, notificationData, token) => {
  const res = await axios.put(`${API_URL}/${notificationId}`, notificationData, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};

// ---------- DELETE OPERATIONS ----------
// -------- DELETE NOTIFICATION --------
export const deleteNotification = async (notificationId, token) => {
  const res = await axios.delete(`${API_URL}/${notificationId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};