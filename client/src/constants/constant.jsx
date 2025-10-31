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