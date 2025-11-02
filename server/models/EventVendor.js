export default (sequelize, DataTypes) => {
    const EventVendor = sequelize.define('EventVendor', {
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
        vendor_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'vendors', key: 'id' },
            onDelete: 'CASCADE',
        },
    }, {
        tableName: 'event_vendors',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
        // --- prevent duplicate entries for the same event & vendor ---
        indexes: [
            {
                unique: true,
                fields: ['event_id', 'vendor_id'],
            },
        ],
    });

    // ---------- EVENT VENDOR ASSOCIATIONS ----------
    EventVendor.associate = (models) => {
        // --- An event vendor belongs to one event and one vendor ---
        EventVendor.belongsTo(models.Event, { foreignKey: 'event_id' });
        EventVendor.belongsTo(models.Vendor, { foreignKey: 'vendor_id' });
    };

    return EventVendor;
}