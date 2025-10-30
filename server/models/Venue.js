export default (sequelize, DataTypes) => {
    const Venue = sequelize.define('Venue', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        address: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        city: {
            type: DataTypes.STRING(100),
            allowNull: false,
        },
        state: {
            type: DataTypes.STRING(100),
            allowNull: false,
        },
        country: {
            type: DataTypes.STRING(100),
            allowNull: false,
        },
        zip_code: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
        capacity: {
            type: DataTypes.INTEGER,
            allowNull: true,
            // --- only allows capacity to be set if > zero ---
            validate: { min: 1 },
        },
    }, {
        tableName: 'venues',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
    });

    // --- Association definition (called by src/models/index.js) ---
    Venue.associate = (models) => {
        // --- Venue associations can be defined here ---
    };
    
    return Venue;
}