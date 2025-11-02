import { Modal } from "../constants/constant";

const SelectTicketTypeModal = ({ isOpen, onClose, ticketTypes, onSelect, onCreate }) => {
  if (!isOpen) return null;

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <h2>Edit or Add Ticket Type</h2>
      {ticketTypes.length === 0 ? (
        <div>
          <p>No ticket types found for this event.</p>
          <button className="createBtn" onClick={onCreate}>Create Ticket Type</button>
        </div>
      ) : (
        // --- if ticket types exist, list them for selection ---
        <div className="selectTicketTypeContainer">
          <p>Select a ticket type to edit:</p>
          <div className="ticketTypeBtnGroup">
            {ticketTypes.map((type) => (
              <button key={type.id} className="ticketTypeBtn" onClick={() => onSelect(type)}>
                {type.name} (${type.price})
              </button>
            ))}
          </div>
          <hr />
          <button className="createBtn" onClick={onCreate}>Add New Ticket Type</button>
        </div>
      )}
    </Modal>
  );
};

export default SelectTicketTypeModal;
