export default (sequelize, DataTypes) => {
    const Event = sequelize.define('Event', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        organizer_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'users', key: 'id' },
            onDelete: 'RESTRICT',
        },
        venue_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'venues', key: 'id' },
            onDelete: 'SET NULL',
        },
        title: {
            type: DataTypes.STRING,
            allowNull: false,
            validate: { 
                notNull: { msg: 'Event Title is required' },
                notEmpty: { msg: 'Event Title cannot be empty' },
            },
        },
        event_type: {
            type: DataTypes.STRING(50),
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT,
        },
        start_date: {
            type: DataTypes.DATE,
            allowNull: false,
            validate: {
                notNull: { msg: 'Start Date is required' },
                isDate: true
            },
        },
        end_date: {
            type: DataTypes.DATE,
            allowNull: false,
            validate: {
                notNull: { msg: 'End Date is required' },
                isDate: true,
            },
        },
        capacity: {
            type: DataTypes.INTEGER,
            allowNull: false,
            // --- only allows capacity to be set if > zero ---
            validate: { min: 1 },
        },
        waitlist_enabled: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        status: {
            type: DataTypes.STRING(50),
            defaultValue: 'scheduled',
        },
    }, {
        tableName: 'events',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
        // --- unique index on title, start_date, and venue_id ---
        // --- prevents duplicate events with same title at same venue on same start_date ---
        indexes: [
            { unique: true, fields: ['title', 'start_date', 'venue_id'] },
        ],
        validate: {
            // --- validates that end_date is after start_date ---
            endDateAfterStartDate() {
                if (this.start_date > this.end_date) {
                    throw new Error('End Date must be after Start Date');
                }
            }
        }
    });

    // ---------- EVENT ASSOCIATIONS ----------
    Event.associate = (models) => {
        // --- event belongs to one organizer (User) & one venue ---
        Event.belongsTo(models.User, { foreignKey: 'organizer_id', as: 'organizer' });
        Event.belongsTo(models.Venue, { foreignKey: 'venue_id', as: 'venue' });

        // --- event can have many ticket types, sessions, registrations, and waitlist entries ---
        Event.hasMany(models.TicketType, { foreignKey: 'event_id', as: 'ticketTypes' });
        Event.hasMany(models.Session, { foreignKey: 'event_id', as: 'sessions' });
        Event.hasMany(models.Registration, { foreignKey: 'event_id', as: 'registrations' });
        Event.hasMany(models.Waitlist, { foreignKey: 'event_id', as: 'waitlistEntries' });

        // --- event can have many attendees through registrations ---
        Event.belongsToMany(models.User, { 
            through: models.Registration,
            foreignKey: 'event_id',
            otherKey: 'user_id',
            as: 'attendees'
        });

        // --- an event can have many notifications, feedback submissions, and metrics ---
        Event.hasMany(models.Notification, { foreignKey: 'event_id', as: 'notifications' });
        Event.hasMany(models.Feedback, { foreignKey: 'event_id', as: 'feedbacks' });
        Event.hasMany(models.EventMetric, { foreignKey: 'event_id', as: 'metrics' });
    };
    
    return Event;
}