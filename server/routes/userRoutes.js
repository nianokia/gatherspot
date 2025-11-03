import express from 'express';

import verifyToken from '../middleware/auth.js';
import { saveFcmToken } from '../controllers/userController.js';

const router = express.Router();

// ---------- SAVE FCM TOKEN ROUTE ----------
router.post('/:userId/fcm-token', verifyToken, saveFcmToken);

export default router;

