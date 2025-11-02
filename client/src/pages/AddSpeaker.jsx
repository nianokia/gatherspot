import { useState } from "react";
import { createSpeaker } from "../api/speaker.jsx";
import { addSpeakersToSession } from "../api/session.jsx";

const AddSpeaker = ({ sessionId, session, token, onClose, onUpdate }) => {
  const [formData, setFormData] = useState({
    name: '', 
    contact_email: '',
    bio: '', 
    photo_url: ''
  });

  // ---------- HANDLE INPUT CHANGES ----------
  const handleChange = (e) => {
    const { name, value } = e.target;
    // --- set changing input while retaining other fields ---
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // --------- HANDLE FORM SUBMISSION ----------
  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const newSpeaker = await createSpeaker(formData, token);
      if (!newSpeaker) throw new Error("Failed to create speaker");
      console.log("createSpeaker response:", newSpeaker);

      // ---------- CREATE SPEAKER ----------
      const newSpeakerId = newSpeaker.speaker.id;

      // ---------- ADD SPEAKER TO SESSION ----------
      const response = await addSpeakersToSession(sessionId, [newSpeakerId], token);
      console.log("addSpeakersToSession response:", response);

      alert("Speaker has been created and added to session!");

      // --- Refresh event details ---
      onUpdate();
      onClose();
    } catch (err) {
      console.error("Error creating speaker:", err);
      alert("Error creating speaker: " + (err?.response?.data?.message || err.message));
    }
  };

  return (
    <div>
      <h1>Add Speaker Page</h1>
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
        <button type="submit">Add Speaker</button>
      </form>
    </div>
    );
};

export default AddSpeaker;