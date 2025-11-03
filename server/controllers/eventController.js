import sgMail from '@sendgrid/mail';

import db from '../models/index.js';

const { User, Event, Venue, TicketType, EventVendor, Notification } = db;

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
        await event.update(updatedData);

        // --- create notification ---
        const notification = await Notification.create({
            event_id: event.id,
            title: 'Event Updated',
            message: `The event "${event.title}" has been updated.`,
            type: 'email',
            target_role: 2,
            schedule_send: new Date(),
        });

        // --- fetch target users ---
        const targetUsers = await User.findAll({
            where: { role_id: notification.target_role } // --- for simplicity, notify only the organizer ---
        });

        const venue = await Venue.findByPk(event.venue_id);

        console.log("Verified sender:", process.env.SENDGRID_VERIFIED_SENDER);
        console.log("SendGrid API Key:", process.env.SENDGRID_API_KEY); // Should NOT be undefined
        // --- send email notifications ---
        for (const user of targetUsers) {
            const msg = {
                to: user.email,
                from: process.env.SENDGRID_VERIFIED_SENDER,
                subject: notification.title,
                text: `
                    ${notification.message}
                    Event Details:
                    Title: ${event.title}
                    Description: ${event.description}
                    Start Date: ${event.start_date}
                    End Date: ${event.end_date}
                    Capacity: ${event.capacity}
                    Is Waitlist Enabled: ${event.waitlist_enabled}
                    Status: ${event.status}
                    Venue Details:
                    Name: ${venue ? venue.name : 'N/A'}
                    Address: ${venue ? venue.address : 'N/A'}
                    City: ${venue ? venue.city : 'N/A'}
                    State: ${venue ? venue.state : 'N/A'}
                    Country: ${venue ? venue.country : 'N/A'}
                    Zip Code: ${venue ? venue.zip_code : 'N/A'}
                    Venue Capacity: ${venue ? venue.capacity : 'N/A'}
                    User Details:
                    Name: ${user.f_name} ${user.l_name}
                    Email: ${user.email}
                    Sent At: ${notification.sent_at}
                `,
                html: `
                    <strong>${notification.message}</strong>
                    <hr />
                    <h2>Event Details:</h2>
                    <p><strong>Title:</strong> ${event.title}</p>
                    <p><strong>Description:</strong> ${event.description}</p>
                    <p><strong>Start Date:</strong> ${event.start_date}</p>
                    <p><strong>End Date:</strong> ${event.end_date}</p>
                    <p><strong>Capacity:</strong> ${event.capacity}</p>
                    <p><strong>Is Waitlist Enabled:</strong> ${event.waitlist_enabled}</p>
                    <p><strong>Status:</strong> ${event.status}</p>
                    <br />
                    <h2>Venue Details:</h2>
                    <ul>
                        <li><strong>Name:</strong> ${event.venue ? event.venue.name : 'N/A'}</li>
                        <li><strong>Address:</strong> ${event.venue ? event.venue.address : 'N/A'}</li>
                        <li><strong>City:</strong> ${event.venue ? event.venue.city : 'N/A'}</li>
                        <li><strong>State:</strong> ${event.venue ? event.venue.state : 'N/A'}</li>
                        <li><strong>Country:</strong> ${event.venue ? event.venue.country : 'N/A'}</li>
                        <li><strong>Zip Code:</strong> ${event.venue ? event.venue.zip_code : 'N/A'}</li>
                        <li><strong>Venue Capacity:</strong> ${event.venue ? event.venue.capacity : 'N/A'}</li>
                    </ul>
                    <hr />
                    <h2>User Details:</h2>
                    <p><strong>Name:</strong> ${user.f_name} ${user.l_name}</p>
                    <p><strong>Email:</strong> ${user.email}</p>
                    <p><strong>Sent At:</strong> ${notification.sent_at}</p>
                `,
            };
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