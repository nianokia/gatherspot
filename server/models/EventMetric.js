export default (sequelize, DataTypes) => {
    const EventMetric = sequelize.define('EventMetric', {
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
        total_tickets_sold: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
        },
        total_revenue: {
            type: DataTypes.DECIMAL(10, 2),
            defaultValue: 0.00,
        },
        attendance_count: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
        },
        no_show_count: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
        },
    }, {
        tableName: 'event_metrics',
        timestamps: false,
        createdAt: false,
        updatedAt: 'last_updated',
    });

    // ---------- EVENT METRIC ASSOCIATIONS ----------
    EventMetric.associate = (models) => {
        // --- An event metric belongs to one event ---
        EventMetric.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    };

    return EventMetric;
}