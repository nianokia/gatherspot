import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const AttendeeDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="AttendeeDash">
      <BackButton />
      <h1>Attendee Dashboard</h1>
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default AttendeeDash;