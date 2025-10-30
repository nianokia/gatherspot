export default (sequelize, DataTypes) => {
    const Session = sequelize.define('Session', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        event_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'events', key: 'id' },
            onDelete: 'CASCADE',
        },
        title: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT,
        },
        start_time: {
            type: DataTypes.DATE,
            allowNull: false,
            validate: { 
                notNull: { msg: 'Start time is required' },
                isDate: true
            },
        },
        end_time: {
            type: DataTypes.DATE,
            allowNull: false,
            validate: {
                notNull: { msg: 'End time is required' },
                isDate: true
            },
        },
        venue_location: {
            type: DataTypes.STRING,
        },
    }, {
        tableName: 'sessions',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
        validate: {
            // --- validates that end_time is after start_time ---
            endTimeAfterStartTime() {
                if (this.start_time.isAfter(this.end_time)) {
                    throw new Error('End Time must be after Start Time');
                }
            }
        }
    });

    // --- Association definition (called by src/models/index.js) ---
    Session.associate = (models) => {
        // --- Session associations can be defined here ---
    };

    return Session;
}