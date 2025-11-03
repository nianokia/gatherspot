import sgMail from '@sendgrid/mail';
import admin from "../firebaseAdmin.js";
import db from '../models/index.js';

const { Session, User, Registration, Event, Notification, EventVendor, Speaker } = db;

// ----------- SENDGRID CONFIGURATION ------------
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// ----------- REUSABLE EMAIL FUNCTION ------------
const sendEmailNotification = async (targetUsers, event, session, venue, notification) => {
    for (const user of targetUsers) {
        const msg = {
            to: user.email,
            from: process.env.SENDGRID_VERIFIED_SENDER,
            subject: notification.title,
            text: `
                Hi ${user.f_name},
                ${notification.message}
                Checkout all event information below!
                Event Details:
                Title: ${event.title}
                Description: ${event.description}
                Start Date: ${event.start_date}
                End Date: ${event.end_date}
                Status: ${event.status}
                --------------
                Venue Details:
                Name: ${venue ? venue.name : 'N/A'}
                Address: ${venue ? venue.address : 'N/A'}
                City: ${venue ? venue.city : 'N/A'}
                State: ${venue ? venue.state : 'N/A'}
                Country: ${venue ? venue.country : 'N/A'}
                Zip Code: ${venue ? venue.zip_code : 'N/A'}
                --------------
                Event Session Details:
                Name: ${session.title}
                Description: ${session.description}
                Venue Location: ${session.venue_location}
                Start Time: ${session.start_time}
                End Time: ${session.end_time}
                Session Speakers:
                ${ (session.speakers && session.speakers.length > 0) ?
                    session.speakers.map(speaker => `- ${speaker.name}`).join('\n')
                    : 'No speakers assigned.'
                }
                We look forward to seeing you!
                Best,
                Gatherspot Team
                Sent At: ${notification.sent_at}
            `,
            html: `
                <h1>Hi ${user.f_name},</h1>
                <h2>${notification.message}</h2>
                <strong>Checkout all event information below!</strong>
                <hr/>
                <h3>Event Details:</h3>
                <p><strong>Title: </strong> ${event.title}</p>
                <p>${event.description ? `<strong>Description: </strong>${event.description}` : ''}</p>
                <p><strong>Start Date: </strong> ${event.start_date}</p>
                <p><strong>End Date: </strong> ${event.end_date}</p>
                <p>${event.status ? `<strong>Status: </strong>${event.status}` : ''}</p>
                --------------
                <h3>Venue Details:</h3>
                <p>${venue.name ? `<strong>Name: </strong>${venue.name}` : ''}</p>
                <p>${venue.address ? `<strong>Address: </strong> ${venue.address}` : ''}</p>
                <p>${venue.city ? `<strong>City: </strong>${venue.city}` : ''}</p>
                <p>${venue.state ? `<strong>State: </strong> ${venue.state}` : ''}</p>
                <p>${venue.country ? `<strong>Country: </strong> ${venue.country}` : ''}</p>
                <p>${venue.zip_code ? `<strong>Zip Code: </strong>${venue.zip_code}` : ''}</p>
                --------------
                <h3>Event Session Details:</h3>
                <p><strong>Title:</strong> ${session.title}</p>
                <p>${session.description ? `<strong>Description: </strong> ${session.description}` : ''}</p>
                <p>${session.venue_location ? `<strong>Venue Location: </strong> ${session.venue_location}` : ''}</p>
                <p><strong>Start Time: </strong> ${session.start_time}</p>
                <p><strong>End Time: </strong> ${session.end_time}</p>
                <br/>
                <h3>Session Speakers:</h3>
                <ul> ${ (session.speakers && session.speakers.length > 0) ?
                    session.speakers.map(speaker => `<li>${speaker.name}</li>`).join('\n')
                    : '<li>No speakers assigned.</li>'
                }
                </ul>
                <hr/>
                <br/>
                <p>We look forward to seeing you!</p>
                <br/>
                <p>Best,</p>
                <br/>
                <p>Gatherspot Team</p>
                <footer>Sent At: ${notification.sent_at}</footer>
            `,
        }
        await sgMail.send(msg);
        console.log(`Notification email sent to ${user.email} for event update.`);
    }
}

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

        const event = await Event.findByPk(fullSession.event_id, { include: ['venue'] });
        const venue = event.venue;

        // --- fetch users associated with the event via EventVendor ---
        const targetVendors = await EventVendor.findAll({ where: { event_id: event.id } });

        // --- fetch users with target_role = 2 (attendees) registered for this event ---
        const targetAttendees = await User.findAll({
            include: [{
                model: Registration,
                where: { event_id: event.id },
                as: 'registrations',
            }],
            where: { role_id: 2 }
        });

        // ------------  !!!!!!!!!    UNCOMMENT THIS LATER    !!!!!!!!!  ------------
        // --- combine vendor and attendee users ---
        // const targetUsers = [...targetVendors, ...targetAttendees];
        const targetUsers = targetAttendees; // --- temporary for testing ---

        // --- create notification ---
        const notification = await Notification.create({
            event_id: session.event_id,
            title: `Event Schedule (${session.title}) added to ${event.title}`,
            message: `We wanted to inform you that an event schedule (${session.title}) was added to ${event.title}.`,
            type: 'email',
            target_role: 2,
        });

        // ------------ SEND EMAIL & PUSH NOTIFICATIONS ------------
        await sendEmailNotification(targetUsers, event, fullSession, venue, notification);
        for (const user of targetUsers) {
            if (user.fcm_token) {
                await sendPushNotification(
                    user.fcm_token,
                    notification.title,
                    notification.message,
                    { eventId: notification.event_id }
                );
            }
        }
        res.status(201).json({ message: 'Session created successfully and email notifications sent', session: fullSession });
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

        const event = await Event.findByPk(updatedSession.event_id, { include: ['venue'] });
        const venue = event.venue;

        // --- fetch users associated with the event via EventVendor ---
        const targetVendors = await EventVendor.findAll({ where: { event_id: event.id } });

        const targetAttendees = await User.findAll({
            include: [{
                model: Registration,
                where: { event_id: event.id },
                as: 'registrations',
            }],
            where: { role_id: 2 }
        });

        // ------------  !!!!!!!!!    UNCOMMENT THIS LATER    !!!!!!!!!  ------------
        // --- combine vendor and attendee users ---
        // const targetUsers = [...targetVendors, ...targetAttendees];
        const targetUsers = targetAttendees; // --- temporary for testing ---

        // --- create notification ---
        const notification = await Notification.create({
            event_id: session.event_id,
            title: `Speaker/ Performer was added to ${event.title}`,
            message: `We wanted to inform you that a speaker/ performer was added to ${event.title}.`,
            type: 'email',
            target_role: 2,
        });

        // ------------ SEND EMAIL & PUSH NOTIFICATIONS ------------
        await sendEmailNotification(targetUsers, event, updatedSession, venue, notification);
        for (const user of targetUsers) {
            if (user.fcm_token) {
                await sendPushNotification(
                    user.fcm_token,
                    notification.title,
                    notification.message,
                    { eventId: notification.event_id }
                );
            }
        }
        res.status(200).json({ message: 'Speakers added to session successfully and email notifications sent', session: updatedSession });
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
        const targetVendors = await EventVendor.findAll({ where: { event_id: event.id } });

        const targetAttendees = await User.findAll({
            include: [{
                model: Registration,
                where: { event_id: event.id },
                as: 'registrations',
            }],
            where: { role_id: 2 }
        });

        // ------------  !!!!!!!!!    UNCOMMENT THIS LATER    !!!!!!!!!  ------------
        // --- combine vendor and attendee users ---
        // const targetUsers = [...targetVendors, ...targetAttendees];
        const targetUsers = targetAttendees; // --- temporary for testing ---

        // --- create notification ---
        const notification = await Notification.create({
            event_id: session.event_id,
            title: `Updates to ${event.title}'s Event Schedules`,
            message: `We wanted to inform you that the event schedules for ${event.title} have been updated.`,
            type: 'email',
            target_role: 2,
        });

        // ------------ SEND EMAIL & PUSH NOTIFICATIONS ------------
        await sendEmailNotification(targetUsers, event, updatedSession, venue, notification);
        for (const user of targetUsers) {
            if (user.fcm_token) {
                await sendPushNotification(
                    user.fcm_token,
                    notification.title,
                    notification.message,
                    { eventId: notification.event_id }
                );
            }
        }
        res.status(200).json({ message: 'Session updated successfully & notifications sent', session: updatedSession });
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

        //  --- fetch event and venue before deleting session ---
        const event = await Event.findByPk(session.event_id, { include: ['venue'] });
        const venue = event.venue;
        
        await session.destroy();

        // --- fetch users associated with the event via EventVendor ---
        const targetVendors = await EventVendor.findAll({ where: { event_id: event.id } });

        const targetAttendees = await User.findAll({
            include: [{
                model: Registration,
                where: { event_id: event.id },
                as: 'registrations',
            }],
            where: { role_id: 2 }
        });

        // ------------  !!!!!!!!!    UNCOMMENT THIS LATER    !!!!!!!!!  ------------
        // --- combine vendor and attendee users ---
        // const targetUsers = [...targetVendors, ...targetAttendees];
        const targetUsers = targetAttendees; // --- temporary for testing ---

        // --- create notification ---
        const notification = await Notification.create({
            event_id: session.event_id,
            title: `Event Schedule (${session.title}) deleted from ${event.title}`,
            message: `We wanted to inform you that an event schedule (${session.title}) has been deleted from ${event.title}.`,
            type: 'email',
            target_role: 2,
        });

        // ------------ SEND EMAIL & PUSH NOTIFICATIONS ------------
        await sendEmailNotification(targetUsers, event, session, venue, notification);
        for (const user of targetUsers) {
            if (user.fcm_token) {
                await sendPushNotification(
                    user.fcm_token,
                    notification.title,
                    notification.message,
                    { eventId: notification.event_id }
                );
            }
        }
        res.status(200).json({ message: 'Session deleted successfully and email notifications sent' });
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

        const event = await Event.findByPk(updatedSession.event_id, { include: ['venue'] });
        const venue = event.venue;

        const speaker = await Speaker.findByPk(speakerId);

        // --- fetch vendor users associated with the event via EventVendor ---
        const targetVendors = await EventVendor.findAll({ where: { event_id: event.id } });

        const targetAttendees = await User.findAll({
            include: [{
                model: Registration,
                where: { event_id: event.id },
                as: 'registrations',
            }],
            where: { role_id: 2 }
        });

        // ------------  !!!!!!!!!    UNCOMMENT THIS LATER    !!!!!!!!!  ------------
        // --- combine vendor and attendee users ---
        // const targetUsers = [...targetVendors, ...targetAttendees];
        const targetUsers = targetAttendees; // --- temporary for testing ---

        // --- create notification ---
        const notification = await Notification.create({
            event_id: session.event_id,
            title: `Speaker/ Performer (${speaker.name}) removed from ${event.title}`,
            message: `We wanted to inform you that a speaker/ performer (${speaker.name}) was removed from ${event.title}.`,
            type: 'email',
            target_role: 2,
        });

        // ------------ SEND EMAIL & PUSH NOTIFICATIONS ------------
        await sendEmailNotification(targetUsers, event, updatedSession, venue, notification);
        for (const user of targetUsers) {
            if (user.fcm_token) {
                await sendPushNotification(
                    user.fcm_token,
                    notification.title,
                    notification.message,
                    { eventId: notification.event_id }
                );
            }
        }
        res.status(200).json({ message: 'Speaker removed from session successfully', session: updatedSession });
    } catch (err) {
        console.error('Error removing speaker from session:', err);
        res.status(500).json({ message: 'Error removing speaker from session', error: err });
    }
};