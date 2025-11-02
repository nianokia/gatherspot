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
        },
    }, {
        tableName: 'venues',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
    });

    // ---------- VENUE ASSOCIATIONS ----------
    Venue.associate = (models) => {
        // --- A venue can have many events ---
        Venue.hasMany(models.Event, { foreignKey: 'venue_id', as: 'events' })
    };
    
    return Venue;
}