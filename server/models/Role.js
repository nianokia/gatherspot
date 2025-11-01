export default (sequelize, DataTypes) => {
    const Role = sequelize.define('Role', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        name: {
            type: DataTypes.STRING(50),
            allowNull: false,
            unique: true,
        },
    }, {
        tableName: 'roles',
        timestamps: false,
    });

    // ---------- ROLE ASSOCIATIONS ----------
    Role.associate = (models) => {
        // --- A role can have many users ---
        Role.hasMany(models.User, { foreignKey: 'role_id', as: 'users' });
    };

    return Role;
}