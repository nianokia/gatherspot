import db from '../models/index.js';

async function testDBConnection() {
    try {
        await db.sequelize.authenticate();
        console.log('Database connection has been established successfully.');
    } catch (err) {
        console.error('Unable to connect to the database:', err);
    }
};

const syncDB = async () => {
    try {
        await db.sequelize.sync({ alter: true });
        console.log('Database synchronized successfully.');
        console.log('All models were synchronized successfully.');
    } catch (err) {
        console.error('Error synchronizing the database:', err);
    }
};

export { testDBConnection, syncDB };