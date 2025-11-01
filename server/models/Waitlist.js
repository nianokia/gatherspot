export default (sequelize, DataTypes) => {
    const Waitlist = sequelize.define('Waitlist', {
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
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'users', key: 'id' },
            onDelete: 'CASCADE',
        },
        status: {
            type: DataTypes.STRING(50),
            allowNull: false,
            defaultValue: 'waiting',
        },
    }, {
        tableName: 'waitlists',
        timestamps: true,
        createdAt: 'requested_at',
        updatedAt: 'updated_at',
        // --- unique index on event_id & user_id ---
        // --- prevents duplicate waitlist entries for the same user & event ---
        indexes: [
            { unique: true, fields: ['event_id', 'user_id'] },
        ],
        validate: {
            // --- validate status is one of the allowed values ---
            validateStatus() {
                const validStatuses = ['waiting', 'notified', 'converted', 'expired'];
                if (!validStatuses.includes(this.status)) {
                    throw new Error('Invalid status');
                }
            },
        }
    });

    // ---------- WAITLIST ASSOCIATIONS ----------
    Waitlist.associate = (models) => {
        // --- A waitlist entry belongs to one event and one user ---
        Waitlist.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
        Waitlist.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    };

    return Waitlist;
}