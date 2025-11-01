import express from 'express';
import { createTicketType } from '../controllers/ticketTypeController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Ticket Type route ---
router.post('/create-ticket-type', createTicketType);

export default router;