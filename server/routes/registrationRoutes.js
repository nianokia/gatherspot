import express from 'express';
import { createRegistration, getRegistrationsByUser, deleteRegistration } from '../controllers/registrationController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Registration route ---
router.post('/register', createRegistration);

// ------------ READ ROUTES ------------
// --- Fetch registerations by user ID route ---
router.get('/user/:userId', getRegistrationsByUser)

// ----------- DELETE ROUTES ------------
// --- Delete Registration route ---
router.delete('/:registrationId', deleteRegistration);

export default router;