import db from '../models/index.js';

const { Speaker } = db;

// ------------ POST OPERATIONS ------------
// ---------- CREATE SPEAKER ----------
export const createSpeaker = async (req, res) => {
    const { user_id, name, bio, contact_email, image_url } = req.body;
    try {
        const speaker = await Speaker.create({ user_id, name, bio, contact_email, image_url });
        res.status(201).json({ message: 'Speaker created successfully', speaker });
    } catch (err) {
        res.status(500).json({ message: 'Error creating speaker', error: err });
    }
};


// ------------ GET OPERATIONS ------------
// ---------- GET SPEAKER BY ID ----------
export const getSpeakerById = async (req, res) => {
    const { id } = req.params;
    try {
        const speaker = await Speaker.findByPk(id);
        if (!speaker) return res.status(404).json({ message: 'Speaker not found' });
        res.status(200).json({ message: 'Speaker fetched successfully', speaker });
    } catch (err) {
        res.status(500).json({ message: 'Error fetching speaker', error: err });
    }
};


// ------------ PUT OPERATIONS ------------
// ---------- UPDATE SPEAKER ----------
export const updateSpeaker = async (req, res) => {
    const { id } = req.params;
    const updatedData = req.body;
    try {
        const speaker = await Speaker.findByPk(id);
        if (!speaker) {
            return res.status(404).json({ message: 'Speaker not found' });
        }
        await speaker.update(updatedData);
        res.status(200).json({ message: 'Speaker updated successfully', speaker });
    } catch (err) {
        res.status(500).json({ message: 'Error updating speaker', error: err });
    }
};


// ------------ DELETE OPERATIONS ------------
// ---------- DELETE SPEAKER ----------
export const deleteSpeaker = async (req, res) => {
    const { id } = req.params;
    try {
        const speaker = await Speaker.findByPk(id);
        if (!speaker) {
            return res.status(404).json({ message: 'Speaker not found' });
        }
        await speaker.destroy();
        res.status(200).json({ message: 'Speaker deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting speaker', error: err });
    }
};