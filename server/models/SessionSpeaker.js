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
        // --- prevent duplicate entries for the same session & speaker ---
        indexes: [
            {
                unique: true,
                fields: ['session_id', 'speaker_id'],
            },
        ],
    });

    // ---------- SESSION SPEAKER ASSOCIATIONS ----------
    SessionSpeaker.associate = (models) => {
        // --- A session speaker belongs to one session and one speaker ---
        SessionSpeaker.belongsTo(models.Session, { foreignKey: 'session_id' });
        SessionSpeaker.belongsTo(models.Speaker, { foreignKey: 'speaker_id' });
    };

    return SessionSpeaker;
}