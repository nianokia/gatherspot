export default (sequelize, DataTypes) => {
    const User = sequelize.define('User', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        role_id: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: { model: 'roles', key: 'id' },
        },
        f_name: {
            type: DataTypes.STRING(100),
            allowNull: false,
            validate: {
                notNull: { msg: 'First name is required' },
                notEmpty: { msg: 'First name cannot be empty' },
            }
        },
        l_name: {
            type: DataTypes.STRING(100),
            allowNull: false,
            validate: {
                notNull: { msg: 'Last name is required' },
                notEmpty: { msg: 'Last name cannot be empty' },
            }
        },
        phone: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
        email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
            validate: { 
                isEmail: true,
                notNull: { msg: 'Email is required' },
                notEmpty: { msg: 'Email cannot be empty' },
             },
        },
        password: {
            type: DataTypes.TEXT,
            allowNull: false,
            validate: {
                notNull: { msg: 'Password is required' },
                notEmpty: { msg: 'Password cannot be empty' },
            }
        },
        is_active: {
            type: DataTypes.BOOLEAN,
            defaultValue: true,
        },
    }, {
        tableName: 'users',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at',
    });

    // ---------- USER ASSOCIATIONS ----------
    User.associate = (models) => {
        // --- A user belongs to one role ---
        User.belongsTo(models.Role, { foreignKey: 'role_id', as: 'role' });
        User.hasMany(models.Event, { foreignKey: 'organizer_id' });
    };
    
    return User;
}
