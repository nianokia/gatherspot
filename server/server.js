import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import path, { dirname } from 'path';
import { fileURLToPath } from 'url';
import { testDBConnection, syncDB } from './db/index.js';
import authRoutes from './routes/authRoutes.js';

const app = express();
const PORT = process.env.PORT || 4000;

// -------- DEFINE PATH to the index.html in the build folder --------
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// ---------- APP USES ----------
app.use(cors());
app.use(express.json());

// ---------- DEFINE API ROUTES ----------
app.use('/api/auth', authRoutes);

// --- direct server to use the compiled build files from React ---
app.use(express.static(path.join(__dirname, '../client/dist')));

// --- Check server ---
app.get('/', (req, res) => {
  // --- verify that all routes are given index.html to allow React to manage routing ---
  res.sendFile(path.join(__dirname, '../client/dist', 'index.html'));
  console.log('Welcome to GatherSpot!');
});

// --- Start server ---
const startServer = async () => {
  console.log('Starting GatherSpot server...');
  await testDBConnection();
  await syncDB();
  app.listen(PORT, () => {
    console.log(`GatherSpot server is running on http://localhost:${PORT}`);
  });
};

startServer();

export default app;