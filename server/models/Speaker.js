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

    // --- Association definition (called by src/models/index.js) ---
    Speaker.associate = (models) => {
        // --- Speaker associations can be defined here ---
    };

    return Speaker;
}