export default (sequelize, DataTypes) => {
    const Feedback = sequelize.define('Feedback', {
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
            references: { model: 'users', key: 'id' },
            onDelete: 'SET NULL',
        },
        rating: {
            type: DataTypes.INTEGER,
            allowNull: false,
            // --- rating between 1 and 5 ---
            validate: {
                min: 1,
                max: 5,
            },
        },
        comments: {
            type: DataTypes.TEXT,
        },
    }, {
        tableName: 'feedback',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: false,
    });

    // ---------- FEEDBACK ASSOCIATIONS ----------
    Feedback.associate = (models) => {
        // --- A feedback belongs to one event and can belong to one user ---
        Feedback.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
        Feedback.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    };

    return Feedback;
}