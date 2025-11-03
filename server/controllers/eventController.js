import sgMail from '@sendgrid/mail';

import db from '../models/index.js';

const { User, Event, Venue, TicketType, EventVendor, Session, Notification } = db;

// ----------- SENDGRID CONFIGURATION ------------
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// ------------ POST OPERATIONS ------------
// ---------- CREATE EVENT ----------
export const createEvent = async (req, res) => {
    const { eventDetails, venueDetails } = req.body;

    // --- if eventDetails has a venue_id, use it ---
    let chosenVenueId = eventDetails?.venue_id;
    let chosenVenue = null;
    let existingVenue = null;
    let committed = false;

    // --- initialize transaction ---
    const transaction = await db.sequelize.transaction();

    try {
        // --- if no venue_id provided, create or find venue ---
        if (!chosenVenueId && venueDetails) {
            // --- check if venue already exists ---
            existingVenue = await Venue.findOne({
                where: {
                    name: venueDetails.name,
                    address: venueDetails.address,
                }
            });

            // --- if venue exists, use it, otherwise, create it ---
            if (existingVenue) {
                chosenVenueId = existingVenue.id;
            } else {
                chosenVenue = await Venue.create(venueDetails, { transaction });
                chosenVenueId = chosenVenue.id;
            }
        }

        // --- verify that chosenVenueId is no longer null ---
        if (!chosenVenueId) {
            throw new Error('Venue information is required to create an event.');
        }

        // --- create the event with the chosen venue_id ---
        const eventData = { ...eventDetails, venue_id: chosenVenueId };
        const newEvent = await Event.create(eventData, { transaction });

        // --- save both records by committing the transaction ---
        await transaction.commit();
        committed = true;

        res.status(201).json({
            message: 'Event with venue created successfully',
            event: newEvent,
            venue: chosenVenue || existingVenue
        });
    } catch (err) {
        // --- if transaction not committed, rollback transaction ---
        if (!committed) await transaction.rollback();

        console.error('Error creating Event with Venue:', err);
        res.status(500).json({ message: 'Internal server error: Error creating Event with Venue', error: err });
    }
};

// // ---------- ADD VENDOR TO EVENT ----------
export const addVendorToEvent = async (req, res) => {
    const { eventId } = req.params;
    const { vendor_id } = req.body;
    try {
        // --- find the event ---
        const event = await EventVendor.create({ event_id: eventId, vendor_id });
        if (!event) return res.status(404).json({ message: "Event not found", EventVendor });

        res.status(200).json({ message: "Vendor added to event successfully", event });
    } catch (err) {
        console.error('Error adding Vendor to Event:', err);
        res.status(500).json({ message: 'Internal server error: Error adding Vendor to Event', error: err });
    }
};


// ------------ READ OPERATIONS ------------
// // ---------- GET ALL EVENTS ----------
export const getAllEvents = async (req, res) => {
    try {
        // --- find all events and include venue & organizer details ---
        const events = await Event.findAll({
            include: [
                { model: Venue, as: 'venue', attributes: ['name', 'address', 'city', 'state', 'country', 'zip_code', 'capacity'] },
                { model: User, as: 'organizer', attributes: ['f_name', 'l_name', 'email'] },
            ]
        });
        if (!events) return res.status(404).json({ message: "No events found" });
        res.status(200).json({ message: "Events fetched successfully", events });
    } catch (err) {
        console.error('Error fetching Events:', err);
        res.status(500).json({ message: 'Internal server error: Error fetching Events', error: err });
    }
};

// ---------- GET EVENT BY ID ----------
export const getEventById = async (req, res) => {
    const { eventId } = req.params;
    try {
        // --- find event and include venue & organizer details ---
        const event = await Event.findByPk(eventId, {
            include: [
                { model: Venue, as: 'venue', attributes: ['name', 'address', 'city', 'state', 'country', 'zip_code', 'capacity'] },
                { model: User, as: 'organizer', attributes: ['f_name', 'l_name', 'email'] },
                { model: TicketType, as: 'ticketTypes' }
            ]
        });
        if (!event) return res.status(404).json({ message: "Event not found" });
        res.status(200).json({ event });
    } catch (err) {
        console.error('Error fetching Event by ID:', err);
        res.status(500).json({ message: 'Internal server error: Error fetching Event by ID', error: err });
    }
};

// ---------- GET EVENTS BY ORGANIZER ----------
export const getEventsByOrganizer = async (req, res) => {
    const { organizerId } = req.params;
    try {
        // --- find all events where organizer_id matches ---
        // --- include venue and organizer details ---
        const events = await Event.findAll({
            where: { organizer_id: organizerId },
            include: [
                { model: Venue, as: 'venue', attributes: ['name', 'address', 'city', 'state', 'country', 'zip_code', 'capacity'] },
                { model: User, as: 'organizer', attributes: ['f_name', 'l_name', 'email'] },
                { model: TicketType, as: 'ticketTypes' }
            ]
        });
        if (!events || events.length === 0) return res.status(404).json({ message: "No events found for this organizer" });
        res.status(200).json({ events });
    } catch (err) {
        console.error('Error fetching Events by Organizer:', err);
        res.status(500).json({ message: 'Internal server error: Error fetching Events by Organizer', error: err });
    }
};

// ---------- GET EVENTS BY VENUE ----------
export const getEventsByVenue = async (req, res) => {
    const { venueId } = req.params;
    try {
        // --- find all events where venue_id matches ---
        // --- include venue and organizer details ---
        const events = await Event.findAll({
            where: { venue_id: venueId },
            include: [
                { model: Venue, as: 'venue', attributes: ['name', 'address', 'city', 'state', 'country', 'zip_code', 'capacity'] },
                { model: User, as: 'organizer', attributes: ['f_name', 'l_name', 'email'] },
                { model: TicketType, as: 'ticketTypes' }
            ]
        });
        if (!events || events.length === 0) return res.status(404).json({ message: "No events found for this venue" });
        res.status(200).json({ message: "Venue's Events fetched successfully", events });
    } catch (err) {
        console.error('Error fetching Events by Venue:', err);
        res.status(500).json({ message: 'Internal server error: Error fetching Events by Venue', error: err });
    }
};

// ------------ PUT OPERATIONS ------------
// ---------- UPDATE EVENT ----------
export const updateEvent = async (req, res) => {
    const { eventId } = req.params;
    const updatedData = req.body;

    try {
        const event = await Event.findByPk(eventId);
        if (!event) return res.status(404).json({ message: "Event not found" });

        // --- update event with new data ---
        const updatedEvent = await event.update(updatedData);

        // --- create notification ---
        const notification = await Notification.create({
            event_id: event.id,
            title: `The Event (${event.title}) has been updated`,
            message: `We wanted to inform you that ${event.title} has been updated.`,
            type: 'email',
            target_role: 2,
        });

        // --- fetch target users ---
        const targetUsers = await User.findAll({
            where: { role_id: notification.target_role }
        });

        // --- fetch related data for email content ---
        const sessions = await Session.findAll({ where: { event_id: event.id }});
        const speakerObjs = await Session.findAll({
            where: { event_id: eventId },
            include: ['speakers']
        });
        // speakers is an array of Session instances, each with speakers array
        const speakers = speakerObjs.flatMap(session =>
            session.speakers.map(speaker => speaker.name)
        );

        console.log("speakers:", speakers);
        const venue = await Venue.findByPk(updatedEvent.venue_id);

        // ------------ SEND EMAIL NOTIFICATIONS ------------
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
                    Event Sessions:
                    ${ (sessions && sessions.length > 0) ?
                        sessions.map(session => `- ${session.title}`).join('\n')
                        : 'No sessions assigned.'
                    }
                    Session Speakers:
                    ${ (speakers && speakers.length > 0) ?
                        speakers.map(speaker => `- ${speaker}`).join('\n')
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
                    <h3>Event Sessions:</h3>
                    <ul>${ (sessions && sessions.length > 0) ?
                        sessions.map(session => `<li>${session.title}</li>`).join('\n')
                        : '<li>No sessions assigned.</li>'
                    }
                    </ul>
                    <br/>
                    <h3>Session Speakers:</h3>
                    <ul> ${ (speakers && speakers.length > 0) ?
                        speakers.map(speaker => `<li>${speaker}</li>`).join('\n')
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

        res.status(200).json({ message: "Event updated successfully", event, notification });
    } catch (err) {
        console.error('Error updating event or sending notification:', err);
        res.status(500).json({ message: 'Internal server error: Error updating Event', error: err });
    }
};

// ------------ DELETE OPERATIONS ------------
// ---------- DELETE EVENT ----------
export const deleteEvent = async (req, res) => {
    const { eventId } = req.params;
    try {
        const event = await Event.findByPk(eventId);
        if (!event) return res.status(404).json({ message: "Event not found" });

        await event.destroy();
        res.status(200).json({ message: "Event deleted successfully" });
    } catch (err) {
        console.error('Error deleting Event:', err);
        res.status(500).json({ message: 'Internal server error: Error deleting Event', error: err });
    }
};