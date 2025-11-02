import express from 'express';
import { createVendor, getEventsByVendorId, getAllVendors, updateVendor, deleteVendor } from '../controllers/vendorController.js';

const router = express.Router();

// ------------ CREATE ROUTES ------------
// --- Create Vendor route ---
router.post('/', createVendor);


// ------------ READ ROUTES ------------
// ---------- Fetch all vendors ----------
router.get('/', getAllVendors);

// ---------- Fetch events by vendor ID ----------
router.get('/:vendorId/events', getEventsByVendorId);


// ----------- UPDATE ROUTES ------------
// ---------- Update Vendor route ----------
router.put('/:vendorId', updateVendor);


// ----------- DELETE ROUTES ------------
// --- Delete Vendor route ---
router.delete('/:vendorId', deleteVendor);

export default router;