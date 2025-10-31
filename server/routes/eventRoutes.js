import express from 'express';
import { createEvent } from '../controllers/eventController.js';

const router = express.Router();

// --- Create Event route ---
router.post('/create-event', createEvent);

export default router;