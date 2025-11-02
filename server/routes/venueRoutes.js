import express from 'express';
import { createVenue, updateVenue } from '../controllers/venueController.js';

const router = express.Router();

// --- Create Venue route ---
router.post('/create', createVenue);

// --- Update Venue route ---
router.put('/update/:id', updateVenue);

export default router;