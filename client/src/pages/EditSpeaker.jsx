import { useState, useEffect } from "react";
import { updateSpeaker } from "../api/speaker";
import { removeSpeakerFromSession } from "../api/session";

const EditSpeaker = ({ speakers, sessionId, token, onClose, onUpdate }) => {
  // --- if multiple speakers, load first speaker's data or '' ---
  const [formData, setFormData] = useState({
    name: speakers && speakers.length > 0 ? speakers[0].name : '',
    contact_email: speakers && speakers.length > 0 ? speakers[0].contact_email : '',
    bio: speakers && speakers.length > 0 ? speakers[0].bio : '',
    photo_url: speakers && speakers.length > 0 ? speakers[0].photo_url : ''
  });
  // --- if multiple speakers, then select the first one ---
  const [active, setActive] = useState(speakers && speakers.length > 0 ? 0 : null);

  console.log("Editing speaker:", speakers);

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    // --- set changing input while retaining other fields ---
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // --- When active speaker changes, update form data ---
  useEffect(() => {
    if (speakers && speakers.length > 0 && active !== null) {
      const speaker = speakers[active];
      setFormData({
        name: speaker.name || '',
        contact_email: speaker.contact_email || '',
        bio: speaker.bio || '',
        photo_url: speaker.photo_url || ''
      });
    }
  }, [active, speakers]);

  const handleSpeakerSelect = (speakerId) => {
    setActive(speakerId);
    const speaker = speakers[speakerId];
    setFormData({ ...formData, speaker_id: speaker.id });
  };

  // --------- HANDLE FORM SUBMISSION ----------
  const handleSubmit = async (e) => {
    e.preventDefault();
    const speaker = speakers[active];

    try {
      // ---------- UPDATE SPEAKER ----------
      const response = await updateSpeaker(speaker.id, formData, token);
      if (!response) throw new Error("Failed to update speaker");

      console.log("updateSpeaker response:", response);
      alert("Speaker has been updated!"); 

      // --- Refresh event details ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error("Error creating speaker:", err);
      alert("Error creating speaker: " + (err?.response?.data?.message || err.message));
    }
  };

  const handleRemoveSpeaker = async (sessionId, speakerId, token) => {
    try {
      const response = await removeSpeakerFromSession(sessionId, speakerId, token);
      console.log("removeSpeakerFromSession response:", response);
      alert("Speaker has been removed from session!");

      // --- Refresh event details ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error("Error removing speaker from session:", err);
      alert("Error removing speaker from session: " + (err?.response?.data?.message || err.message));
    }
  };

  return (
    <div className="EditSpeaker">
      <h1>Edit Speaker Page</h1>
      <div className="buttonGroup">
        {speakers && speakers.length > 0 && (
          speakers.map((speaker, index) => (
            <button 
              type="button" 
              key={speaker.id} 
              id={index} 
              className={active === index ? 'active' : ''} 
              onClick={() => handleSpeakerSelect(index)}
            >
              {speaker.name}
            </button>
          ))
        )}
      </div>
      {/* ---------- ADD SPEAKER FORM ---------- */}
      <form className='AddSpeakerForm' onSubmit={handleSubmit}>
        <div className="formGroup">
          <label htmlFor="name" className="required">Name:</label>
          <input type="text" id="name" name="name" placeholder="Name"
            value={formData.name} onChange={handleChange} required />
        </div>
        <div className="formGroup">
          <label htmlFor="bio">Bio:</label>
          <input type="text" id="bio" name="bio" placeholder="Bio"
            value={formData.bio} onChange={handleChange}/>
        </div>
        <div className="formGroup">
          <label htmlFor="contact_email">Email:</label>
          <input type="text" id="contact_email" name="contact_email" placeholder="Email"
            value={formData.contact_email} onChange={handleChange}/>
        </div>
        <div className="formGroup">
          <label htmlFor="photo_url">Photo URL:</label>
          <input type="text" id="photo_url" name="photo_url" placeholder="Photo URL"
            value={formData.photo_url} onChange={handleChange}/>
        </div>
        <div className="editSpeakerBtnGroup">
          <button type="submit">Edit Speaker</button>
          <button type="button" onClick={() => handleRemoveSpeaker(sessionId, speakers[active].id, token)}>Remove Speaker</button>
        </div>
      </form>
    </div>
  );
};

export default EditSpeaker;