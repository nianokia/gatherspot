import express from 'express';
import {
    getEventMetrics,
    getEventTicketSales,
    getEventAttendance,
    getEventRevenue,
    getNoShowCount
} from '../controllers/eventMetricController.js';

const router = express.Router();

// --------- GET OPERATIONS ---------
// --- Route to get all event metrics ---
router.get('/:eventId/metrics', getEventMetrics);

// --- Route to get ticket sales data for an event ---
router.get('/:eventId/ticket-sales', getEventTicketSales);

// --- Route to get attendance data for an event ---
router.get('/:eventId/attendance', getEventAttendance);

// --- Route to get revenue data for an event ---
router.get('/:eventId/revenue', getEventRevenue);

// --- Route to get no-show data for an event ---
router.get('/:eventId/no-show', getNoShowCount);

export default router;