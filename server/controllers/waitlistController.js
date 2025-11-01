import db from '../models/index.js';

const { Waitlist } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE REGISTRATION ----------
export const addToWaitlist = async (req, res) => {
    // ---------- EXTRACT WAITLIST DETAILS FROM REQ.BODY ----------
    const { event_id, user_id } = req.body;

    try {
        // ---------- CREATE NEW WAITLIST ENTRY ----------
        const newWaitlistEntry = await Waitlist.create({
            event_id,
            user_id,
            status: 'waiting'
        });

        // ---------- RESPOND WITH NEW WAITLIST ENTRY INFO ----------
        res.status(201).json({ message: 'Added to waitlist successfully', waitlistEntry: newWaitlistEntry });
    } catch (err) {
        console.error('Error adding to waitlist:', err);
        res.status(500).json({ message: 'Internal server error: Error adding to waitlist', error: err });
    }
};