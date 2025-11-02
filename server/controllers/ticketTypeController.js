import db from "../models/index.js";

const { TicketType } = db;

// ------------ CREATE OPERATIONS ------------
// ---------- CREATE TICKET TYPE CONTROLLER ----------
export const createTicketType = async (req, res) => {
    // ---------- EXTRACT TICKET TYPE DETAILS FROM REQ.BODY ----------
    const { event_id, name, price, quantity, sale_start, sale_end } = req.body;

    try {
        // ---------- CREATE NEW USER ----------
        const newTicketType = await TicketType.create({
            event_id,
            name,
            price,
            quantity,
            sale_start,
            sale_end
        });

        // ---------- RESPOND WITH NEW TICKET TYPE INFO ----------
        res.status(201).json({ message: "Ticket Type created successfully", ticketType: newTicketType });
    } catch (err) {
        console.error("Error creating Ticket Type:", err);
        res.status(500).json({ error: "An error occurred while creating the Ticket Type." });
    }
};

// ------------ READ OPERATIONS ------------
// ---------- GET ALL EVENT'S TICKET TYPES CONTROLLER ----------
export const getAllEventTicketTypes = async (req, res) => {
    try {
        const eventId = req.params.eventId;
        const ticketTypes = await TicketType.findAll({ where: { event_id: eventId } });
        res.status(200).json({ ticketTypes });
    } catch (err) {
        console.error("Error fetching Ticket Types for Event:", err);
        res.status(500).json({ error: "An error occurred while fetching the Ticket Types for the Event." });
    }
};

// ---------- GET TICKET TYPE BY ID CONTROLLER ----------
export const getTicketTypeById = async (req, res) => {
    const ticketTypeId = req.params.id;

    try {
        const ticketType = await TicketType.findByPk(ticketTypeId);
        if (!ticketType) {
            return res.status(404).json({ error: "Ticket Type not found." });
        }
        res.status(200).json({ ticketType });
    } catch (err) {
        console.error("Error fetching Ticket Type by ID:", err);
        res.status(500).json({ error: "An error occurred while fetching the Ticket Type." });
    }
};

// ------------ UPDATE OPERATIONS ------------
// ---------- UPDATE TICKET TYPE CONTROLLER ----------
export const updateTicketType = async (req, res) => {
    const ticketTypeId = req.params.id;
    const updatedData = req.body;

    try {
        const ticketType = await TicketType.findByPk(ticketTypeId);
        if (!ticketType) {
            return res.status(404).json({ error: "Ticket Type not found." });
        }

        await ticketType.update(updatedData);
        res.status(200).json({ message: "Ticket Type updated successfully", ticketType });
    } catch (err) {
        console.error("Error updating Ticket Type:", err);
        res.status(500).json({ error: "An error occurred while updating the Ticket Type." });
    }
};

// ------------ DELETE OPERATIONS ------------