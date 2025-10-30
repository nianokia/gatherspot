export default (sequelize, DataTypes) => {
    const Registration = sequelize.define('Registration', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'users', key: 'id' },
            onDelete: 'CASCADE',
        },
        ticket_type_id: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'ticket_types', key: 'id' },
            onDelete: 'RESTRICT',
        },
        qr_code: {
            type: DataTypes.TEXT,
            allowNull: false,
            unique: true,
        },
        status: {
            type: DataTypes.ENUM('active', 'used', 'cancelled', 'refunded'),
            allowNull: false,
            defaultValue: 'active',
        },
        check_in: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        check_in_time: {
            type: DataTypes.DATE,
        },
    }, {
        tableName: 'registrations',
        timestamps: true,
        createdAt: 'purchase_date',
        updatedAt: 'updated_at',
    });

    // --- Association definition (called by src/models/index.js) ---
    Registration.associate = (models) => {
        // --- Registration associations can be defined here ---
    };

    return Registration;
}