import express from 'express';
import { addToWaitlist } from '../controllers/waitlistController';
const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Add to Waitlist route ---
router.post('/add', addToWaitlist);

export default router;