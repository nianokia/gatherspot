import express from 'express';
import { createEvent, getAllEvents } from '../controllers/eventController.js';

const router = express.Router();

// --- Create Event route ---
router.post('/create-event', createEvent);

// --- Get All Events route ---
router.get('/', getAllEvents);

export default router;