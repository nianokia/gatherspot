import sgMail from '@sendgrid/mail';

import db from '../models/index.js';

const { Venue, User, Event, Session, Notification } = db;

// ----------- SENDGRID CONFIGURATION ------------
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

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

        const updatedVenue = await venue.update(updatedData);

        // --- fetch the event associated with the session ---
        const event = await Event.findOne({ where: { venue_id: venue.id } });
        console.log(event)
        const session = await Session.findOne({
            where: { event_id: event.id },
            include: ['speakers']
        });

        // --- create notification ---
        const notification = await Notification.create({
            event_id: event.id,
            title: `The Event Venue for ${event.title} has been updated`,
            message: `We wanted to inform you that the event venue for ${event.title} has been updated.`,
            type: 'email',
            target_role: 2,
        });

        // --- fetch target users ---
        const targetUsers = await User.findAll({
            where: { role_id: notification.target_role }
        });

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

        res.status(200).json({ message: "Venue updated successfully", venue: updatedVenue });
    } catch (err) {
        console.error("Error updating Venue:", err);
        res.status(500).json({ error: "An error occurred while updating the Venue." });
    }
};