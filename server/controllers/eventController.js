import db from '../models/index.js';

const { User, Event, Venue } = db;

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

// ------------ READ OPERATIONS ------------
// // ---------- GET ALL EVENTS ----------
export const getAllEvents = async (req, res) => {
    try {
        const events = await Event.findAll({
            include: [
                { model: Venue, as: 'venue', attributes: ['name', 'address', 'city', 'state', 'country', 'zip_code', 'capacity'] },
                { model: User, as: 'organizer', attributes: ['f_name', 'l_name', 'email'] },
            ]
        });
        if (!events) return res.status(404).json({ message: "No events found" });
        res.status(200).json({ events });
    } catch (err) {
        console.error('Error fetching Events:', err);
        res.status(500).json({ message: 'Internal server error: Error fetching Events', error: err });
    }
};

// ---------- GET EVENT BY ID ----------
export const getEventById = async (req, res) => {
    const { eventId } = req.params;
    try {
        const event = await Event.findByPk(eventId, {
            include: [
                { model: Venue, as: 'venue', attributes: ['name', 'address', 'city', 'state', 'country', 'zip_code', 'capacity'] },
                { model: User, as: 'organizer', attributes: ['f_name', 'l_name', 'email'] },
            ]
        });
        if (!event) return res.status(404).json({ message: "Event not found" });
        res.status(200).json({ event });
    } catch (err) {
        console.error('Error fetching Event by ID:', err);
        res.status(500).json({ message: 'Internal server error: Error fetching Event by ID', error: err });
    }
};