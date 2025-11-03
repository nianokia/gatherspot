import admin from 'firebase-admin';

admin.initializeApp({
    // --- This automatically uses GOOGLE_APPLICATION_CREDENTIALS ---
    credential: admin.credential.applicationDefault(),
    projectId: 'gatherspot-f9b3a', 
});

export default admin;
