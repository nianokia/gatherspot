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