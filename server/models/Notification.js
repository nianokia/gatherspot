export default (sequelize, DataTypes) => {
    const Notification = sequelize.define('Notification', {
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
        message: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        type: {
            type: DataTypes.ENUM('push', 'email', 'in-app'),
            allowNull: false,
        },
        target_role: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: { model: 'roles', key: 'id' },
            onDelete: 'RESTRICT',
        },
        is_read: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
    }, {
        tableName: 'notifications',
        timestamps: true,
        createdAt: 'sent_at',
        updatedAt: false,
    });

    // --- Association definition (called by src/models/index.js) ---
    Notification.associate = (models) => {
        // --- Notification associations can be defined here ---
    };

    return Notification;
}