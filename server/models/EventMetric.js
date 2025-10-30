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

    // --- Association definition (called by src/models/index.js) ---
    EventMetric.associate = (models) => {
        // --- EventMetric associations can be defined here ---
    };

    return EventMetric;
}