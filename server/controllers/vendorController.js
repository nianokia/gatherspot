import db from '../models/index.js';

const { EventVendor, Event, Vendor } = db;

// ----------- POST OPERATIONS ------------
// ---------- CREATE VENDOR ----------
export const createVendor = async (req, res) => {
    const { user_id, company_name, contact_email, phone } = req.body;

    try {
        const newVendor = await Vendor.create({
            user_id,
            company_name,
            contact_email,
            phone
        });
        if (!newVendor) return res.status(404).json({ message: "Vendor not found", vendor: newVendor });

        res.status(201).json({
            message: 'Vendor created successfully',
            vendor: newVendor
        });
    } catch (error) {
        console.error("Error creating vendor: ", error);
        res.status(500).json({ message: "Internal Server Error creating vendor", error: error.message });
    }
};

// ------------ GET OPERATIONS ------------
// ---------- FETCH ALL VENDORS ----------
export const getAllVendors = async (req, res) => {
    try {
        const vendors = await Vendor.findAll();
        if (!vendors) return res.status(404).json({ message: "No vendors found" });
        res.status(200).json({ message: 'Vendors fetched successfully', vendors });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ---------- FETCH EVENTS BY VENDOR ID ----------
export const getEventsByVendorId = async (req, res) => {
    const { vendor_id } = req.params;
    try {
        const events = await EventVendor.findAll({
            where: { vendor_id },
            include: [{ model: Event, as: 'event' }]
        });
        res.json(200).json({ message: 'Events fetched successfully', events });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ----------- PUT OPERATIONS ------------
// ---------- UPDATE VENDOR ----------
export const updateVendor = async (req, res) => {
    const { vendorId } = req.params;
    const { company_name, contact_email, phone } = req.body;

    try {
        const vendor = await Vendor.findByPk(vendorId);
        if (!vendor) return res.status(404).json({ message: "Vendor not found" });

        await vendor.update({
            company_name: company_name || vendor.company_name,
            contact_email: contact_email || vendor.contact_email,
            phone: phone || vendor.phone
        });

        res.status(200).json({ message: "Vendor updated successfully", vendor });
    } catch (error) {
        console.error("Error updating vendor: ", error);
        res.status(500).json({ message: "Error updating vendor", error: error.message });
    }
};

// ----------- DELETE OPERATIONS ------------
// ---------- DELETE VENDOR ----------
export const deleteVendor = async (req, res) => {
    const { vendorId } = req.params;
    try {
        const deleted = await Vendor.findByPk(vendorId);
        if (!deleted) return res.status(404).json({ message: "Vendor not found" });
        
        await Vendor.destroy({ where: { id: vendorId } });
        res.status(200).json({ message: "Vendor deleted successfully" });
    } catch (error) {
        console.error("Error deleting vendor: ", error);
        res.status(500).json({ error: error.message });
    }
};