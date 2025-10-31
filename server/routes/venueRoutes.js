import express from 'express';
import { createVenue } from '../controllers/venueController.js';

const router = express.Router();

// --- Create Venue route ---
router.post('/create-venue', createVenue);

export default router;