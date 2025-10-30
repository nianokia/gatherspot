export default (sequelize, DataTypes) => {
    const SessionSpeaker = sequelize.define('SessionSpeaker', {
        session_id: {
            type: DataTypes.UUID,
            primaryKey: true,
            allowNull: false,
            references: { model: 'sessions', key: 'id' },
            onDelete: 'CASCADE',
        },
        speaker_id: {
            type: DataTypes.UUID,
            primaryKey: true,
            allowNull: false,
            references: { model: 'speakers', key: 'id' },
            onDelete: 'CASCADE',
        },
    }, {
        tableName: 'session_speakers',
        timestamps: false,
    });

    // --- Association definition (called by src/models/index.js) ---
    SessionSpeaker.associate = (models) => {
        // --- SessionSpeaker associations can be defined here ---
    };

    return SessionSpeaker;
}