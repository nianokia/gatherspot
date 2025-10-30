import { Sequelize, DataTypes } from 'sequelize';
import defineUser from './User.js';

// ---------- INITIALIZE SEQUELIZE ----------
const sequelize = new Sequelize(process.env.DATABASE_URI, {
    dialect: 'postgres',
    logging: false,
});
// --- Initialize db object ---
const db = {};

// --- Pass sequelize instance & DataTypes to model definitions ---
db.User = defineUser(sequelize, DataTypes);

// --- If there are associations, define them here ---
Object.keys(db).forEach(modelName => {
    if (db[modelName].associate) {
        db[modelName].associate(db);
    }
});

// --- Export the db object with key/ value pairs ---
db.sequelize = sequelize;
db.Sequelize = Sequelize;
db.DataTypes = DataTypes;

export default db;