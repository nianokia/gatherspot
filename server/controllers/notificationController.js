import admin from "../firebaseAdmin.js";
import db from "../models/index.js";

const { Notification } = db;

// ---------- SEND PUSH NOTIFICATION ----------
export const sendPushNotification = async (fcmToken, title, body, data = {}) => {
    // --- construct message ---
    // --- data = an optional place for client to include additional key-value pairs ---
    const message = {
        token: fcmToken,
        notification: { title, body },
        data
    };

    try {
        // --- send the message ---
        const response = await admin.messaging().send(message);
        console.log("Push notification sent successfully", response);
        return response;
    } catch (err) {
        console.error("Error sending push notification:", err);
        throw err;
    }
};

// ----------- POST OPERATIONS ------------
// ---------- CREATE NOTIFICATION ----------
export const createNotification = async (req, res) => {
    const { event_id, title, message, scheduled_time } = req.body;

    try {
        const newNotification = await Notification.create({
            event_id,
            title,
            message,
            type,
            target_role: 2, // --- default to attendee id ---
            scheduled_time
        });
        if (!newNotification) return res.status(404).json({ message: "Notification not created", notification: newNotification });

        res.status(201).json({
            message: 'Notification created successfully',
            notification: newNotification
        });
    } catch (error) {
        console.error("Error creating notification: ", error);
        res.status(500).json({ message: "Internal Server Error creating notification", error: error.message });
    }
};

// ------------ GET OPERATIONS ------------
// ---------- FETCH ALL NOTIFICATIONS ----------
export const getNotifications = async (req, res) => {
    try {
        const notifications = await Notification.findAll();
        res.status(200).json({ message: 'Notifications fetched successfully', notifications });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ---------- FETCH NOTIFICATIONS BY EVENT ID ----------
export const getNotificationsByEventId = async (req, res) => {
    const { event_id } = req.params;
    try {
        const notifications = await Notification.findAll({
            where: { event_id }
        });
        res.status(200).json({ message: 'Notifications fetched successfully', notifications });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ----------- PUT OPERATIONS ------------
// ---------- UPDATE NOTIFICATION ----------
export const updateNotification = async (req, res) => {
    const { notificationId } = req.params;
    const { title, message, scheduled_time } = req.body;

    try {
        const notification = await Notification.findByPk(notificationId);
        if (!notification) {
            return res.status(404).json({ message: 'Notification not found' });
        }

        notification.title = title || notification.title;
        notification.message = message || notification.message;
        notification.scheduled_time = scheduled_time || notification.scheduled_time;

        await notification.save();

        res.status(200).json({
            message: 'Notification updated successfully',
            notification
        });
    } catch (error) {
        console.error("Error updating notification: ", error);
        res.status(500).json({ message: "Internal Server Error updating notification", error: error.message });
    }
};

// ---------- DELETE NOTIFICATION ----------
export const deleteNotification = async (req, res) => {
    const { notificationId } = req.params;

    try {
        const notification = await Notification.findByPk(notificationId);
        if (!notification) {
            return res.status(404).json({ message: 'Notification not found' });
        }

        await notification.destroy();

        res.status(200).json({ message: 'Notification deleted successfully' });
    } catch (error) {
        console.error("Error deleting notification: ", error);
        res.status(500).json({ message: "Internal Server Error deleting notification", error: error.message });
    }
};