import express from 'express';
import { createSpeaker, getSpeakerById, updateSpeaker, deleteSpeaker } from '../controllers/speakerController.js';

const router = express.Router();

// ------------ POST OPERATIONS ------------
// ---------- CREATE SPEAKER ----------
router.post('/', createSpeaker);

// ------------ GET OPERATIONS ------------
// ---------- GET SPEAKER BY ID ----------
router.get('/:id', getSpeakerById);

// ------------ PUT OPERATIONS ------------
// ---------- UPDATE SPEAKER ----------
router.put('/:id', updateSpeaker);

// ------------ DELETE OPERATIONS ------------
// ---------- DELETE SPEAKER ----------
router.delete('/:id', deleteSpeaker);

export default router;