import express from 'express';
import { 
    createEvent, 
    getAllEvents, 
    getEventById, 
    getEventsByOrganizer, 
    getEventsByVenue, 
    updateEvent,
    deleteEvent 
} from '../controllers/eventController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Event route ---
router.post('/create-event', createEvent);


// ------------ READ ROUTES ------------
// --- Get All Events route ---
router.get('/', getAllEvents);

// --- Get Event by ID route ---
router.get('/:eventId', getEventById);

// --- Get Events by Organizer route ---
router.get('/organizer/:organizerId', getEventsByOrganizer);

// --- Get Events by Venue route ---
router.get('/venue/:venueId', getEventsByVenue);


// ------------ PUT ROUTES ------------
// --- Update Event route ---
router.put('/:eventId', updateEvent);


// ------------ DELETE ROUTES ------------
// --- Delete Event route ---
router.delete('/:eventId', deleteEvent);

export default router;