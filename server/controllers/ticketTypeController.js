import db from "../models/index.js";

const { TicketType } = db;

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