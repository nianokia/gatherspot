import db from '../models/index.js';

const { User } = db;

// ---------- SAVE FCM TOKEN FOR USER ----------
export const saveFcmToken = async (req, res) => {
    const { userId } = req.params;
    const { fcm_token } = req.body;

    try {
        const user = await User.findByPk(userId);
        if (!user) return res.status(404).json({ message: 'User not found.' });
        
        // --- add FCM token to user ---
        user.fcm_token = fcm_token;

        // --- Save updated user ---
        await user.save();

        res.status(200).json({ message: 'FCM token saved successfully for user events.' });
    } catch (error) {
        console.error('Error saving FCM token:', error);
        res.status(500).json({ message: 'Internal server error saving FCM token.', error });
    }
};