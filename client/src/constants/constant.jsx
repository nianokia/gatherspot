import { useNavigate } from "react-router";

// ----------- BACK BUTTON --------
export const BackButton = () => {
  const navigate = useNavigate();
  const handleBack = () => {
    navigate(-1);
  };

  return (
    <button onClick={handleBack} className="backBtn">
      ← Back
    </button>
  )
}

export const Modal = ({ isOpen, onClose, children }) => {
  if (!isOpen) return null;

  return (
    // --- Close modal when clicking outside modal ---
    <div className="modal-overlay" onClick={onClose}>
      {/* --- Prevent closing when clicking inside modal --- */}
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose}>&times;</button>
        {children}
      </div>
    </div>
  );
};

export const ConfirmModal = ({
  isOpen,
  onClose,
  onConfirm,
  title = "Are you sure you want to proceed?",
  message = "This action is permanent and can't be undone.",
  confirmText = "Confirm",
  cancelText = "Cancel",
  cancelColor = "#d9534f"
}) => {
  if (!isOpen) return null;

  const handleConfirm = async () => {
    await onConfirm();
    // --- close modal after confirmation ---
    onClose();
  }

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <h3>{title}</h3>
      <p>{message}</p>
      <div className="modal-actions">
        <button onClick={handleConfirm} className="confirmBtn">
          {confirmText}
        </button>
        <button onClick={onClose} className="cancelBtn" style={{ backgroundColor: cancelColor}}>
          {cancelText}
        </button>
      </div>
    </Modal>
  )
}

export const OptionsModal = ({ isOpen, onClose, title, action1, action2, action3, option1, option2, option3 }) => {
  if (!isOpen) return null;

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <h2>{title}</h2>
      <div className="optionsGroup">
        {action1 && <button className="optionBtn" onClick={action1}>{option1}</button>}
        {action2 && <button className="optionBtn" onClick={action2}>{option2}</button>}
        {action3 && <button className="optionBtn" onClick={action3}>{option3}</button>}
      </div>
    </Modal>
  );
};

export const formatDate = (date) => {
  // --- define options for formatting ---
  const options = {
    weekday: 'short',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    hour12: true,
  };

  // --- create new Date object and format it ---
  // --- undefined is for default locale/ timezone ---
  const formattedDate = new Date(date).toLocaleString(undefined, options);
  return formattedDate;
};