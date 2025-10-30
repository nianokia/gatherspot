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

    // --- Association definition (called by src/models/index.js) ---
    Vendor.associate = (models) => {
        // --- Vendor associations can be defined here ---
    };

    return Vendor;
}