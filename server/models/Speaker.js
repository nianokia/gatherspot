export default (sequelize, DataTypes) => {
    const Speaker = sequelize.define('Speaker', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        user_id: {
            type: DataTypes.UUID,
            unique: true,
            references: { model: 'users', key: 'id' },
            onDelete: 'SET NULL',
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        contact_email: {
            type: DataTypes.STRING,
            validate: { isEmail: true },
        },
        bio: {
            type: DataTypes.TEXT,
        },
        image_url: {
            type: DataTypes.TEXT,
        },
    }, {
        tableName: 'speakers',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
    });

    // ---------- SPEAKER ASSOCIATIONS ----------
    Speaker.associate = (models) => {
        // --- A speaker can be belong to one user ---
        Speaker.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });

        // --- A speaker can speak at many sessions ---
        Speaker.belongsToMany(models.Session, { 
            through: models.SessionSpeaker, 
            foreignKey: 'speaker_id', 
            as: 'sessions' 
        });
    };

    return Speaker;
}