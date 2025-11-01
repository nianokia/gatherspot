import db from '../models/index.js';
import QRCode from 'qrcode';

const { Registration } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE REGISTRATION ----------
export const createRegistration = async (req, res) => {
    // ---------- EXTRACT REGISTRATION DETAILS FROM REQ.BODY ----------
    const { user_id, event_id, ticket_type_id } = req.body;

    // --------- CREATE QR CODE DATA ----------
    // const qrCodeData = `Registration-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    // const qrCodeImage = await QRCode.toDataURL(qrCodeData);

    const generateQR = async text => {
        try {
            const qrCode = QRCode.toDataURL(text);
            res.status(200).json({ qrCode });
        } catch (err) {
            console.error('Error generating QR code:', err);
            res.status(500).json({ message: 'Internal server error: Error generating QR code', error: err.message });
            throw err;
        }
    }

    try {
        // ---------- CREATE NEW REGISTRATION ----------
        const newRegistration = await Registration.create({
            user_id,
            event_id,
            ticket_type_id,
            // simple QR code generation
            qr_code: await generateQR(`text`),
            status: 'active'
        });

        // ---------- RESPOND WITH NEW REGISTRATION INFO ----------
        res.status(201).json({ message: 'Registration created successfully', registration: newRegistration });
    } catch (err) {
        console.error('Error creating registration:', err);
        res.status(500).json({ message: 'Internal server error: Error creating registration', error: err });
    }
};