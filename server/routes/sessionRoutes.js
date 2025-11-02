import express from 'express';
import { createSession } from '../controllers/sessionController.js';

const router = express.Router();

// ---------- CREATE ROUTES ----------
// --- Create a new session ---
router.post('/', createSession);

export default router;