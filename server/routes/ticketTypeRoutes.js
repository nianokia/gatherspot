import express from 'express';
import { createTicketType, updateTicketType } from '../controllers/ticketTypeController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Ticket Type route ---
router.post('/create', createTicketType);

// ------------ UPDATE ROUTES ------------
// --- Update Ticket Type route ---
router.put('/update/:id', updateTicketType);
export default router;