import db from '../models/index.js';

const { Session } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE SESSION ----------
export const createSession = async (req, res) => {
    // --- destructure req.body ---
    const { eventId, title, description, start_time, end_time, venue_location, speakerIds } = req.body;
  
    try {
        // --- add all session fields except speakerIds ---
        const session = await Session.create({ event_id: eventId, title, description, start_time, end_time, venue_location });
        
        // --- associate speakers to session if provided ---
        if (speakerIds && speakerIds.length > 0) {
            // --- addSpeakers stems from Session.belongsToMany association ---
            await session.addSpeakers(speakerIds);
        }

        // --- fetch & return the session with associated speakers ---
        const fullSession = await Session.findByPk(session.id, { include: ['speakers'] });
        res.status(201).json({ message: 'Session created successfully', session: fullSession });
    } catch (err) {
        console.error('Error creating session:', err);
        res.status(500).json({ message: 'Error creating session', error: err });
    }
};


// ------------ GET OPERATIONS ------------
// ---------- GET SESSIONS BY EVENT ID ----------
export const getSessionsForEvent = async (req, res) => {
    const { eventId } = req.params;
    try {
        // --- fetch sessions with associated speakers ---
        const sessions = await Session.findAll({
            where: { event_id: eventId },
            include: ['speakers']
        });
        res.status(200).json({ sessions });
    } catch (err) {
        console.error('Error fetching sessions for event:', err);
        res.status(500).json({ message: 'Error fetching sessions for event', error: err.message });
    }
};