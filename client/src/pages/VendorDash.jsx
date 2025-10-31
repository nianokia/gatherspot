import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const VendorDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="VendorDash">
      <BackButton />
      <h1>Vendor Dashboard</h1>
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default VendorDash;