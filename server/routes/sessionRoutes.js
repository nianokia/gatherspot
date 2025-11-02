import express from 'express';
import { createSession, getSessionsForEvent } from '../controllers/sessionController.js';

const router = express.Router();

// ---------- CREATE ROUTES ----------
// --- Create a new session ---
router.post('/', createSession);

// ---------- GET ROUTES ----------
// --- Get all sessions for a specific event ---
router.get('/event/:eventId', getSessionsForEvent);

export default router;