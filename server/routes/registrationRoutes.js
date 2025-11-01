import express from 'express';
import { createRegistration } from '../controllers/registrationController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Registration route ---
router.post('/register', createRegistration);

export default router;