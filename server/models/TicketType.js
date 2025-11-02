export default (sequelize, DataTypes) => {
    const TicketType = sequelize.define('TicketType', {
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
        name: {
            type: DataTypes.STRING(100),
            allowNull: false,
        },
        price: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
            // --- only allows price to be set if >= zero ---
            validate: { min: 0 },
        },
        quantity: {
            type: DataTypes.INTEGER,
            allowNull: false,
            // --- only allows quantity to be set if > zero ---
            validate: { min: 1 },
        },
        sale_start: {
            type: DataTypes.DATE,
            // validate: { isDate: true },
        },
        sale_end: {
            type: DataTypes.DATE,
            // validate: { isDate: true },
        },
    }, {
        tableName: 'ticket_types',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
        // --- unique index on event_id and name ---
        // --- prevents duplicate ticket type names for the same event ---
        indexes: [
            { unique: true, fields: ['event_id', 'name'] },
        ],
    });

    // ---------- TICKET TYPE ASSOCIATIONS ----------
    TicketType.associate = (models) => {
        // --- A ticket type belongs to one event ---
        TicketType.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });

        // --- A ticket type can have many registrations ---
        TicketType.hasMany(models.Registration, { foreignKey: 'ticket_type_id', as: 'registrations' });
    };

    return TicketType;
}