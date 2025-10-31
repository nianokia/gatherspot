import db from '../models/index.js';

const { Venue } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE VENUE ----------
export const createVenue = async (req, res) => {
    try {
        const { name, address, city, state, country, zip_code, capacity } = req.body;

        // --- validate required fields ---
        if (!name || !address || !city || !state || !country) {
            return res.status(400).json({ message: "Missing required venue fields" });
        }

        // --- create new venue ---
        const newVenue = await Venue.create({
            name,
            address,
            city,
            state,
            country,
            zip_code,
            capacity
        });

        res.status(201).json({ message: 'Venue created successfully', venue: newVenue });
    } catch (err) {
        console.error('Error creating Venue:', err);
        res.status(500).json({ message: 'Internal server error: Error creating Venue', error: err });
    }
};