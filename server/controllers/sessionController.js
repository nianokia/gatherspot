import db from '../models/index.js';

const { Session } = db;

// - Fetch sessions with their speakers using Sequelize include.

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

// ---------- ADD SPEAKERS TO SESSION ----------
export const addSpeakersToSession = async (req, res) => {
    const { sessionId } = req.params;
    // --- expects an array of speaker IDs ---
    const { speakerIds } = req.body;

    try {
        const session = await Session.findByPk(sessionId);
        if (!session) return res.status(404).json({ message: 'Session not found' });

        // --- fetch current speakers to avoid duplicates ---
        const currentSpeakers = await session.getSpeakers();
        const currentSpeakerIds = currentSpeakers.map(speaker => speaker.id);
        console.log('Current Speaker IDs:', currentSpeakerIds);

        // --- filter out speakerIds that are already associated ---
        const newSpeakerIds = speakerIds.filter(id => !currentSpeakerIds.includes(id));
        if (newSpeakerIds.length === 0) {
            return res.status(400).json({ message: 'All speakers already added to this session.' });
        }

        // --- add speakers to session ---
        await session.addSpeakers(newSpeakerIds);

        // --- fetch & return the updated session with associated speakers ---
        const updatedSession = await Session.findByPk(sessionId, { include: ['speakers'] });
        res.status(200).json({ message: 'Speakers added to session successfully', session: updatedSession });
    } catch (err) {
        console.error('Error adding speakers to session:', err);
        res.status(500).json({ message: 'Error adding speakers to session', error: err });
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
        res.status(200).json({ message: 'Event\'s Sessions fetched successfully', sessions });
    } catch (err) {
        console.error('Error fetching sessions for event:', err);
        res.status(500).json({ message: 'Error fetching sessions for event', error: err.message });
    }
};


// ------------ PUT OPERATIONS ------------
// ---------- UPDATE SESSION ----------
export const updateSession = async (req, res) => {
    const { sessionId } = req.params;
    const updatedData = req.body;

    try {
        // --- fetch the session by ID ---
        const session = await Session.findByPk(sessionId);
        if (!session) return res.status(404).json({ message: 'Session not found' });

        await session.update(updatedData);

        // --- fetch & return the updated session with associated speakers ---
        const updatedSession = await Session.findByPk(sessionId, { include: ['speakers'] });
        res.status(200).json({ message: 'Session updated successfully', session: updatedSession });
    } catch (err) {
        console.error('Error updating session:', err);
        res.status(500).json({ message: 'Error updating session', error: err });
    }
};

// ------------ DELETE OPERATIONS ------------
// ---------- DELETE SESSION ----------
export const deleteSession = async (req, res) => {
    const { sessionId } = req.params;

    try {
        const session = await Session.findByPk(sessionId);
        if (!session) return res.status(404).json({ message: 'Session not found' });

        await session.destroy();
        res.status(200).json({ message: 'Session deleted successfully' });
    } catch (err) {
        console.error('Error deleting session:', err);
        res.status(500).json({ message: 'Error deleting session', error: err });
    }
};

// ---------- REMOVE SPEAKER FROM SESSION ----------
export const removeSpeakerFromSession = async (req, res) => {
    const { sessionId, speakerId } = req.params;

    try {
        const session = await Session.findByPk(sessionId);
        if (!session) return res.status(404).json({ message: 'Session not found' });

        // --- remove the association between session & speaker ---
        await session.removeSpeaker(speakerId);

        // --- fetch & return the updated session with associated speakers ---
        const updatedSession = await Session.findByPk(sessionId, { include: ['speakers'] });
        res.status(200).json({ message: 'Speaker removed from session successfully', session: updatedSession });
    } catch (err) {
        console.error('Error removing speaker from session:', err);
        res.status(500).json({ message: 'Error removing speaker from session', error: err });
    }
};