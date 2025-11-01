export default (sequelize, DataTypes) => {
    const Registration = sequelize.define('Registration', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'users', key: 'id' },
            onDelete: 'CASCADE',
        },
        ticket_type_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'ticket_types', key: 'id' },
            onDelete: 'RESTRICT',
        },
        qr_code: {
            type: DataTypes.TEXT,
            allowNull: false,
            unique: true,
        },
        status: {
            type: DataTypes.STRING(50),
            allowNull: false,
            defaultValue: 'active',
        },
        check_in: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        check_in_time: {
            type: DataTypes.DATE,
        },
    }, {
        tableName: 'registrations',
        timestamps: true,
        createdAt: 'purchase_date',
        updatedAt: 'updated_at',
        validate: {
            // --- validate status is one of the allowed values ---
            validateStatus() {
                const validStatuses = ['active', 'used', 'cancelled', 'refunded'];
                if (!validStatuses.includes(this.status)) {
                    throw new Error('Invalid status');
                }
            },
        },
    });

    // ---------- REGISTRATION ASSOCIATIONS ----------
    Registration.associate = (models) => {
        // --- A registration belongs to one attendee, one event, and one ticket type ---
        Registration.belongsTo(models.User, { foreignKey: 'user_id', as: 'attendee' });
        Registration.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
        Registration.belongsTo(models.TicketType, { foreignKey: 'ticket_type_id', as: 'ticketType' });
    };

    return Registration;
}