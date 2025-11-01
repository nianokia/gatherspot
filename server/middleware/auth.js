import jwt from 'jsonwebtoken';

const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        console.log("Decoded JWT payload: ", decoded);

        req.user = {
            userId: decoded.userId,
            role: decoded.role,
        };

        console.log("req.user: ", req.user);

        next();
    } catch (err) {
        console.error("Token verification failed: ", err.message);
        return res.status(403).json({ error: 'Invalid token' });
    }
};

export default verifyToken;