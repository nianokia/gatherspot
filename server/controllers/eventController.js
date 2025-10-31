import db from '../models/index.js';

const { Event, Venue } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE EVENT ----------
export const createEvent = async (req, res) => {
    const { eventDetails, venueDetails } = req.body;

    // --- if eventDetails has a venue_id, use it ---
    let chosenVenueId = eventDetails?.venue_id;
    let chosenVenue = null;

    // --- initialize transaction ---
    const transaction = await db.sequelize.transaction();

    try {
        // --- if no venue_id provided, create or find venue ---
        if (!chosenVenueId && venueDetails) {
            // --- check if venue already exists ---
            const existingVenue = await Venue.findOne({
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

        res.status(201).json({
            message: 'Event with venue created successfully',
            event: newEvent,
            venue: chosenVenue || existingVenue
        });
    } catch (err) {
        // --- if error, rollback transaction ---
        await transaction.rollback();

        console.error('Error creating Event with Venue:', err);
        res.status(500).json({ message: 'Internal server error: Error creating Event with Venue', error: err });
    }
};