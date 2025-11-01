import express from 'express';
import { createRegistration, getRegistrationsByUser } from '../controllers/registrationController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Registration route ---
router.post('/register', createRegistration);

// ------------ READ ROUTES ------------
// --- Fetch registerations by user ID route ---
router.get('/user/:userId', getRegistrationsByUser)

export default router;