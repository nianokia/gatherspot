import sgMail from '@sendgrid/mail';

import db from '../models/index.js';

const { Session, User, Registration, Event, Notification } = db;

// ----------- SENDGRID CONFIGURATION ------------
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

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

        const event = await Event.findByPk(session.event_id, { include: ['venue'] });
        const venue = event.venue;

        // --- fetch users associated with the event via EventVendor ---
        const targetVendors = await db.EventVendor.findAll({ where: { event_id: event.id } });

        // --- fetch users with target_role = 2 (attendees) registered for this event ---
        const targetAttendees = await User.findAll({
            include: [{
                model: Registration,
                where: { event_id: event.id },
                as: 'registrations',
            }],
            where: {
                role_id: 2
            }
        });

        // ------------  !!!!!!!!!    UNCOMMENT THIS LATER    !!!!!!!!!  ------------
        // --- combine vendor and attendee users ---
        // const targetUsers = [...targetVendors, ...targetAttendees];
        const targetUsers = targetAttendees; // --- temporary for testing ---

        // --- create notification ---
        const notification = await Notification.create({
            event_id: session.event_id,
            title: `Updates to ${event.title}'s Event Schedules`,
            message: `We wanted to inform you that the event schedules for "${event.title}" have been updated.`,
            type: 'email',
            target_role: 2,
        });

        // --- send email notifications ---
        for (const user of targetUsers) {
            const msg = {
                to: user.email,
                from: process.env.SENDGRID_VERIFIED_SENDER,
                subject: notification.title,
                text: `
                    Hi ${user.f_name},
                    ${notification.message}
                    Event Session Details:
                    Name: ${updatedSession.title}
                    Description: ${updatedSession.description}
                    Venue Location: ${updatedSession.venue_location}
                    Start Time: ${updatedSession.start_time}
                    End Time: ${updatedSession.end_time}
                    Session Speakers:
                    ${ (updatedSession.speakers && updatedSession.speakers.length > 0) ?
                        updatedSession.speakers.map(speaker => `- ${speaker.name}`).join('\n')
                        : 'No speakers assigned.'
                    }
                    ----------------------------------------
                    Event Details:
                    Title: ${event.title}
                    Description: ${event.description}
                    Start Date: ${event.start_date}
                    End Date: ${event.end_date}
                    Status: ${event.status}
                    Venue Details:
                    Name: ${venue ? venue.name : 'N/A'}
                    Address: ${venue ? venue.address : 'N/A'}
                    City: ${venue ? venue.city : 'N/A'}
                    State: ${venue ? venue.state : 'N/A'}
                    Country: ${venue ? venue.country : 'N/A'}
                    Zip Code: ${venue ? venue.zip_code : 'N/A'}
                    We look forward to seeing you!
                    Best,
                    Gatherspot Team
                    Sent At: ${notification.sent_at}
                `,
                html: `
                    <p>Hi ${user.f_name},</p>
                    <p>${notification.message}</p>
                    <br/>
                    <h1>Event Session Details:</h1>
                    <p><strong>Name:</strong> ${session.title}</p>
                    <p><strong>Description:</strong> ${session.description}</p>
                    <p><strong>Venue Location:</strong> ${session.venue_location}</p>
                    <p><strong>Start Time:</strong> ${session.start_time}</p>
                    <p><strong>End Time:</strong> ${session.end_time}</p>
                    <hr/>
                    <br/>
                    <h2>Session Speakers:</h2>
                    <ul> ${ (updatedSession.speakers && updatedSession.speakers.length > 0) ?
                        updatedSession.speakers.map(speaker => `<li>${speaker.name}</li>`).join('\n')
                        : '<li>No speakers assigned.</li>'
                    }
                    </ul>
                    <br/>
                    ----------------------------------------
                    <h2>Event Details:</h2>
                    <p><strong>Title:</strong> ${event.title}</p>
                    <p><strong>Description:</strong> ${event.description}</p>
                    <p><strong>Start Date:</strong> ${event.start_date}</p>
                    <p><strong>End Date:</strong> ${event.end_date}</p>
                    <p><strong>Status:</strong> ${event.status}</p>
                    <h2>Venue Details:</h2>
                    <p><strong>Name:</strong> ${venue ? venue.name : 'N/A'}</p>
                    <p><strong>Address:</strong> ${venue ? venue.address : 'N/A'}</p>
                    <p><strong>City:</strong> ${venue ? venue.city : 'N/A'}
                    <p><strong>State:</strong> ${venue ? venue.state : 'N/A'}
                    <p><strong>Country:</strong> ${venue ? venue.country : 'N/A'}
                    <p><strong>Zip Code:</strong> ${venue ? venue.zip_code : 'N/A'}
                    <br/>
                    <p>We look forward to seeing you!</p>
                    <br/>
                    <p>Best,</p>
                    <br/>
                    <p>Gatherspot Team</p>
                    <footer>Sent At: ${notification.sent_at}</footer>
                `,
            };
            await sgMail.send(msg);
            console.log(`Notification email sent to ${user.email} for event update.`);
        }

        
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