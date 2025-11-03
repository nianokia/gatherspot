import sgMail from '@sendgrid/mail';
import 'dotenv/config';
import db from "../models/index.js";

const { Notification } = db;

// ----------- SENDGRID CONFIGURATION ------------
// sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// ----------- TEST EMAIL ------------
// const msg = {
//   to: 'test@example.com', // Change to your recipient
//   from: 'test@example.com', // Change to your verified sender
//   subject: 'Sending with SendGrid is Fun',
//   text: 'and easy to do anywhere, even with Node.js',
//   html: '<strong>and easy to do anywhere, even with Node.js</strong>',
// }
// sgMail
//   .send(msg)
//   .then(() => {
//     console.log('Email sent')
//   })
//   .catch((error) => {
//     console.error(error)
//   })

// ----------- POST OPERATIONS ------------
// ---------- CREATE NOTIFICATION ----------
export const createNotification = async (req, res) => {
    const { event_id, title, message, scheduled_time } = req.body;

    try {
        const newNotification = await Notification.create({
            event_id,
            title,
            message,
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