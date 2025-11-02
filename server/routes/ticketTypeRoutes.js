import express from 'express';
import { createTicketType, getAllEventTicketTypes, getTicketTypeById, updateTicketType } from '../controllers/ticketTypeController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Ticket Type route ---
router.post('/create', createTicketType);


// ------------ READ ROUTES ------------
// --- Get all ticket types for an event ---
router.get('/event/:eventId', getAllEventTicketTypes);

// --- Get ticket type by ID ---
router.get('/:id', getTicketTypeById);


// ------------ UPDATE ROUTES ------------
// --- Update Ticket Type route ---
router.put('/update/:id', updateTicketType);
export default router;