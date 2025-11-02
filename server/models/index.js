import { Sequelize, DataTypes } from 'sequelize';
import defineUser from './User.js';
import defineRole from './Role.js';
import defineEvent from './Event.js';
import defineVenue from './Venue.js';
import defineTicketType from './TicketType.js';
import defineRegistration from './Registration.js';
import defineWaitlist from './Waitlist.js';
import defineVendor from './Vendor.js';
import defineSpeaker from './Speaker.js';
import defineSession from './Session.js';
import defineSessionSpeaker from './SessionSpeaker.js';
import defineNotification from './Notification.js';
import defineFeedback from './Feedback.js';
import defineEventMetric from './EventMetric.js';
import defineEventVendor from './EventVendor.js';

// ---------- INITIALIZE SEQUELIZE ----------
const sequelize = new Sequelize(process.env.DATABASE_URI, {
    dialect: 'postgres',
    logging: false,
});
// --- Initialize db object ---
const db = {};

// --- Pass sequelize instance & DataTypes to model definitions ---
db.Role = defineRole(sequelize, DataTypes);
db.User = defineUser(sequelize, DataTypes);
db.Event = defineEvent(sequelize, DataTypes);
db.Venue = defineVenue(sequelize, DataTypes);
db.TicketType = defineTicketType(sequelize, DataTypes);
db.Registration = defineRegistration(sequelize, DataTypes);
db.Waitlist = defineWaitlist(sequelize, DataTypes);
db.Vendor = defineVendor(sequelize, DataTypes);
db.Speaker = defineSpeaker(sequelize, DataTypes);
db.Session = defineSession(sequelize, DataTypes);
db.SessionSpeaker = defineSessionSpeaker(sequelize, DataTypes);
db.Notification = defineNotification(sequelize, DataTypes);
db.Feedback = defineFeedback(sequelize, DataTypes);
db.EventMetric = defineEventMetric(sequelize, DataTypes);
db.EventVendor = defineEventVendor(sequelize, DataTypes);

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