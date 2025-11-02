import express from 'express';
import { createSession, getSessionsForEvent, addSpeakersToSession } from '../controllers/sessionController.js';

const router = express.Router();

// ---------- CREATE ROUTES ----------
// --- Create a new session ---
router.post('/', createSession);

// --- Add speakers to a session ---
router.post('/:sessionId/speakers', addSpeakersToSession);


// ---------- GET ROUTES ----------
// --- Get all sessions for a specific event ---
router.get('/event/:eventId', getSessionsForEvent);

export default router;