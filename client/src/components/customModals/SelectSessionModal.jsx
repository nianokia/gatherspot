import { Modal } from "../../constants/constant";

const SelectSessionModal = ({ isOpen, onClose, sessions, onSelect, onCreate }) => {
  if (!isOpen) return null;

  console.log("SelectSessionModal sessions:", sessions);

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <h2>Pick a Session to add a Speaker/ Performer</h2>
      {sessions.length === 0 ? (
        <div>
          <p>No sessions found for this event.</p>
          <button className="createBtn" onClick={onCreate}>Create Session</button>
        </div>
      ) : (
        // --- if sessions exist, list them for selection ---
        <div className="selectSessionContainer">
          <p>Select a session:</p>
          <div className="sessionBtnGroup">
            {sessions.map((session) => (
              <button key={session.id} className="sessionBtn" onClick={() => onSelect(session)}>
                {session.title}
              </button>
            ))}
          </div>
        </div>
      )}
    </Modal>
  );
};

export default SelectSessionModal;
