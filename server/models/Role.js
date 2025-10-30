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

    // --- Association definition (called by src/models/index.js) ---
    Role.associate = (models) => {
        // --- Role associations can be defined here ---
    };

    return Role;
}