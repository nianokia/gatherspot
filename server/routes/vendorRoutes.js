import express from 'express';
import { getEventsByVendorId, getAllVendors, createVendor, deleteVendor } from '../controllers/vendorController.js';

const router = express.Router();

// ------------ READ ROUTES ------------
// ---------- Fetch all vendors ----------
router.get('/', getAllVendors);

// ---------- Fetch events by vendor ID ----------
router.get('/:vendorId/events', getEventsByVendorId);

// ------------ CREATE ROUTES ------------
// --- Create Vendor route ---
router.post('/', createVendor);

// ----------- DELETE ROUTES ------------
// --- Delete Vendor route ---
router.delete('/:vendorId', deleteVendor);

export default router;