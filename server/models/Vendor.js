export default (sequelize, DataTypes) => {
    const Vendor = sequelize.define('Vendor', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'users', key: 'id' },
        },
        company_name: {
            type: DataTypes.STRING,
        },
        contact_email: {
            type: DataTypes.STRING,
            validate: { isEmail: true },
        },
        phone: {
            type: DataTypes.STRING(20),
        },
    }, {
        tableName: 'vendors',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
    });

    // ---------- VENDOR ASSOCIATIONS ----------
    Vendor.associate = (models) => {
        // --- A vendor belongs to one user ---
        Vendor.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });

        // --- a vendor can have many event vendors and many events through event vendors ---
        Vendor.hasMany(models.EventVendor, { foreignKey: 'vendor_id', as: 'eventVendors' });
        Vendor.belongsToMany(models.Event, { through: models.EventVendor, foreignKey: 'vendor_id', otherKey: 'event_id', as: 'events' });
    };

    return Vendor;   
}