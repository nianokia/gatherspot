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

// ------------ UPDATE OPERATIONS ------------
// ---------- UPDATE VENUE ----------
export const updateVenue = async (req, res) => {
    const venueId = req.params.id;
    const updatedData = req.body;

    try {
        const venue = await Venue.findByPk(venueId);
        if (!venue) {
            return res.status(404).json({ error: "Venue not found." });
        }

        // --- convert empty string to null for capacity ---
        if (updatedData.capacity === "") {
            updatedData.capacity = null;
        }

        // --- validate venue capacity if provided and not null ---
        if (updatedData.capacity !== undefined && updatedData.capacity !== null && updatedData.capacity < 1) {
            return res.status(400).json({ error: "Capacity must be greater than zero." });
        }

        await venue.update(updatedData);
        res.status(200).json({ message: "Venue updated successfully", venue });
    } catch (err) {
        console.error("Error updating Venue:", err);
        res.status(500).json({ error: "An error occurred while updating the Venue." });
    }
};