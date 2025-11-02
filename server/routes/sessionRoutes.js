import express from 'express';
import { createSession, getSessionsForEvent, addSpeakersToSession, updateSession, deleteSession } from '../controllers/sessionController.js';

const router = express.Router();

// GET /api/speakers/:speakerId/sessions to get all sessions for a speaker.

// ---------- CREATE ROUTES ----------
// --- Create a new session ---
router.post('/', createSession);

// --- Add speakers to a session ---
router.post('/:sessionId/speakers', addSpeakersToSession);


// ---------- GET ROUTES ----------
// --- Get all sessions for a specific event ---
router.get('/event/:eventId', getSessionsForEvent);


// ---------- PUT ROUTES ----------
// --- Update session details ---
router.put('/:sessionId', updateSession);


// ---------- DELETE ROUTES ----------
// --- Delete a session ---
router.delete('/:sessionId', deleteSession);

export default router;