import express from 'express';
import { getNotifications, getNotificationsByEventId, createNotification, updateNotification, deleteNotification } from '../controllers/notificationController.js';

const router = express.Router();

// ----------- POST OPERATIONS ------------
// POST /api/notifications/ - Create a new notification
router.post('/', createNotification);

// ------------ GET OPERATIONS ------------
// GET /api/notifications/ - Get all notifications for the authenticated user
router.get('/', getNotifications);

// GET /api/notifications/event/:event_id - Get notifications by event ID
router.get('/event/:event_id', getNotificationsByEventId);

// ----------- PUT OPERATIONS ------------
// PUT /api/notifications/:id - Update a notification by ID
router.put('/:id', updateNotification);

// ----------- DELETE OPERATIONS ------------
// DELETE /api/notifications/:id - Delete a notification by ID
router.delete('/:id', deleteNotification);

export default router;