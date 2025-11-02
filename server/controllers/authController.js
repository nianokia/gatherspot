import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import db from '../models/index.js';
import 'dotenv/config';

const { User, Role, Vendor } = db;

// ---------- DEFINE USER REGISTRATION CONTROLLER ----------
export const register = async (req, res) => {
    // ---------- EXTRACT USER DETAILS FROM REQ.BODY ----------
    const { role_id, f_name, l_name, phone, email, password, is_active } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);

        // ---------- CREATE NEW USER ----------
        const newUser = await User.create({
            role_id,
            f_name,
            l_name,
            phone,
            email,
            password: hashedPassword,
            is_active
        });

        // ---------- FETCH REGISTERED USER WITH ROLE ----------
        const registeredUser = await User.findByPk(newUser.id, {
            attributes: { exclude: ['password'] },
            include: [{ model: Role, as: 'role', attributes: ['name'] }]
        });

        // ---------- GENERATE JWT TOKEN ----------
        const token = jwt.sign(
            { 
                userId: registeredUser.id,
                email: registeredUser.email,
                role: registeredUser.role_id,
            },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        // ---------- IF USER IS A VENDOR, CREATE VENDOR PROFILE ----------
        try {
            if (registeredUser.role_id === 3) {
                const newVendor = await Vendor.create({ user_id: registeredUser.id, token });
                console.log('Vendor profile created for registered user', newVendor);
            }
        } catch (err) {
            console.error('Error creating vendor profile for registered user:', err);
            res.status(500).json({ message: 'Internal server error creating vendor profile', error: err });
            return;
        }

        // ---------- RESPOND WITH TOKEN & USER INFO ----------
        res.status(201).json({
            message: 'User registered successfully',
            token: token,
            user: {
                id: registeredUser.id,
                role_id: registeredUser.role_id,
                role: registeredUser.role.name,
                f_name: registeredUser.f_name,
                l_name: registeredUser.l_name,
                phone: registeredUser.phone,
                email: registeredUser.email,
                is_active: registeredUser.is_active
            }
        });
    } catch (err) {
        console.error('Error registering user:', err);
        res.status(500).json({ message: 'Internal server error registering user', error: err });
    }
};

// ---------- DEFINE USER LOGIN CONTROLLER ----------
export const login = async (req, res) => {
    const { email, password } = req.body;

    try {
        // ---------- FIND USER BY EMAIL ----------
        const user = await User.findOne({ 
            where: { email },
            include: [{ model: Role, as: 'role', attributes: ['name'] }]
        });
        if (!user) {
            console.log('Login FAILED: User not found');
            return res.status(401).json({ message: 'Authentication failed: User not found' });
        }

        // ---------- COMPARE PASSWORDS ----------
        const doesPasswordMatch = await bcrypt.compare(password, user.password);
        if (!doesPasswordMatch) {
            console.log('Login FAILED: Invalid password');
            return res.status(401).json({ message: 'Authentication failed: Invalid password' });
        }

        // ---------- GENERATE JWT TOKEN ----------
        const token = jwt.sign(
            { 
                userId: user.id,
                email: user.email,
                role: user.role_id,
                // role: user.role.name
            },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        // ---------- RESPOND WITH TOKEN & USER INFO ----------
        res.status(200).json({
            message: 'Login successful',
            token: token,
            user: {
                id: user.id,
                role_id: user.role_id,
                role: user.role.name,
                f_name: user.f_name,
                l_name: user.l_name,
                phone: user.phone,
                email: user.email,
                is_active: user.is_active
            }
        });
    } catch (err) {
        console.error('Error logging in user:', err);
        res.status(500).json({ message: 'Internal server error logging in', error: err });
    }
};