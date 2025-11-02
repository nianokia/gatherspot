import express from 'express';
import { createSpeaker } from '../controllers/speakerController.js';

const router = express.Router();

// ------------ POST OPERATIONS ------------
// ---------- CREATE SPEAKER ----------
router.post('/', createSpeaker);

export default router;