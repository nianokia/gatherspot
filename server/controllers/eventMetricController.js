import db from '../models/index.js';

const { EventMetric } = db;

// ---------- GET OPERATIONS ----------
// ---------- GET EVENT METRICS BY EVENT ID ----------  
export const getEventMetrics = async (req, res) => {
    try {
        const { eventId } = req.params;
        const eventMetrics = await EventMetric.findOne({ where: { event_id: eventId } });
        if (!eventMetrics) {
            return res.status(404).json({ message: "No metrics found for this event." });
        }
        console.log("Fetched event metrics: ", eventMetrics);

        res.status(200).json({ message: "Event metrics fetched successfully", data: eventMetrics });
    } catch (err) {
        res.status(500).json({ message: "Error fetching event metrics", error: err.message });
    }
};

// ---------- GET ALL EVENT TICKET SALES ----------
export const getEventTicketSales = async (req, res) => {
    try {
        const { eventId } = req.params;
        const ticketSales = await EventMetric.findOne({ 
            where: { eventId, metricType: 'ticket_sales' }
        });
        console.log("Fetched ticket sales: ", ticketSales);

        res.status(200).json({ message: "Ticket sales fetched successfully", data: ticketSales });
    } catch (err) {
        res.status(500).json({ message: "Error fetching ticket sales", error: err.message });
    }
};

// ---------- GET ALL EVENT ATTENDANCE ----------
export const getEventAttendance = async (req, res) => {
    try {
        const { eventId } = req.params;
        const attendance = await EventMetric.findOne({ 
            where: { event_id: eventId },
            include: ['attendees']
        });
        console.log("Fetched attendance data: ", attendance);

        res.status(200).json({ message: "Attendance data fetched successfully", data: attendance });
    } catch (err) {
        res.status(500).json({ message: "Error fetching attendance data", error: err.message });
    }
};

// ---------- GET ALL EVENT REVENUE ----------
export const getEventRevenue = async (req, res) => {
    try {
        const { eventId } = req.params;
        const revenue = await EventMetric.findOne({
            where: { eventId, metricType: 'revenue' }
        });
        console.log("Fetched revenue data: ", revenue);

        res.status(200).json({ message: "Revenue data fetched successfully", data: revenue });
    } catch (err) {
        res.status(500).json({ message: "Error fetching revenue data", error: err.message });
    }
};

export const getNoShowCount = async (req, res) => {
    try {
        const { eventId } = req.params;
        const noShowData = await EventMetric.findOne({
            where: { eventId, metricType: 'no_show' }
        });
        console.log("Fetched no-show data: ", noShowData);

        res.status(200).json({ message: "No-show data fetched successfully", data: noShowData });
    } catch (err) {
        res.status(500).json({ message: "Error fetching no-show data", error: err.message });
    }
};