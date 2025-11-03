import axios from 'axios';
import { useState, useEffect, createContext, useContext } from 'react';
import { messaging } from '../firebase.js';
import { getToken, onMessage } from 'firebase/messaging';
import AuthContext from './authContext.jsx';

const NotificationsContext = createContext();

export const NotificationsProvider = ({ children }) => {
  const [fcmToken, setFcmToken] = useState(null);
  const [notification, setNotification] = useState(null);
  const { user, token: jwtToken } = useContext(AuthContext);

  // ----- Request FCM token and listen for messages -----
  async function requestFCMToken() {
    try {
      const token = await getToken(messaging, { vapidKey: 'YOUR_VAPID_KEY' });
      
      // --- if token, user, & jwToken exists, save FCM token to server & associate it with user ---
      if (token && user && jwtToken) {
        // --- only save if token has changed ---
        if (token !== fcmToken) {
          axios.post(
            `${import.meta.env.VITE_DOMAIN}/api/users/${user.id}/fcm-token`,
            { fcm_token: token },
            { headers: { Authorization: `Bearer ${jwtToken}` } }
          ).catch(err => console.error('Error saving FCM token to backend', err));
          
          setFcmToken(token);
        }
      }
    } catch (err) {
      console.error('FCM permission denied', err);
    }
  }

  // ----- request FCM token and set notifications whenever user or token changes -----
  useEffect(() => {
    requestFCMToken();

    // --- listen for foreground messages ---
    onMessage(messaging, (payload) => {
      setNotification(payload.notification);
      // --- optionally show a toast or update UI ---
    });
  }, [user, jwtToken, fcmToken]);

  return (
    <NotificationsContext.Provider value={{ fcmToken, notification, setNotification }}>
      {children}
    </NotificationsContext.Provider>
  );
};

export default NotificationsContext;