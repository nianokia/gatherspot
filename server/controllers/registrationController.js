import db from '../models/index.js';
import QRCode from 'qrcode';
import { v4 as uuidv4 } from 'uuid';

const { Registration } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE REGISTRATION ----------
export const createRegistration = async (req, res) => {
    // ---------- EXTRACT REGISTRATION DETAILS FROM REQ.BODY ----------
    const { user_id, event_id, ticket_type_id } = req.body;

    try {
        // ---------- CREATE QR CODE DATA ----------
        // --- generate a UUID registration code ---
        const registration_code = uuidv4();
        // --- generate QR code image ---
        const qrCodeImage = await QRCode.toDataURL(registration_code);

        // ---------- CREATE NEW REGISTRATION ----------
        const newRegistration = await Registration.create({
            user_id,
            event_id,
            ticket_type_id,
            qr_code: qrCodeImage,
            status: 'active',
            checked_in: false,
            check_in_time: null,
            registration_code
        });

        // ---------- RESPOND WITH NEW REGISTRATION INFO ----------
        res.status(201).json({ message: 'Registration created successfully', registration: newRegistration });
    } catch (err) {
        console.error('Error creating registration:', err);
        res.status(500).json({ message: 'Internal server error: Error creating registration', error: err });
    }
};