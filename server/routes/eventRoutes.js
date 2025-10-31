import express from 'express';
import { createEvent, getAllEvents, getEventById } from '../controllers/eventController.js';

const router = express.Router();

// --- Create Event route ---
router.post('/create-event', createEvent);

// --- Get All Events route ---
router.get('/', getAllEvents);

// --- Get Event by ID route ---
router.get('/:eventId', getEventById);

export default router;