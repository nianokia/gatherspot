import db from '../models/index.js';

const { Speaker } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE SPEAKER ----------
export const createSpeaker = async (req, res) => {
    const { user_id, name, bio, contact_email, image_url } = req.body;
    try {
        const speaker = await Speaker.create({ user_id, name, bio, contact_email, image_url });
        res.status(201).json({ speaker });
    } catch (err) {
        res.status(500).json({ message: 'Error creating speaker', error: err });
    }
};