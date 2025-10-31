import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const OrganizerDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="OrganizerDash">
      <BackButton />
      <h1>Organizer Dashboard</h1>
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default OrganizerDash;