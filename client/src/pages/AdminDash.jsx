import { useContext } from 'react';
import { BackButton } from '../constants/constant.jsx';
import AuthContext from '../context/authContext.jsx';

const AdminDash = () => {
  const { logout } = useContext(AuthContext);
  return (
    <div className="AdminDash">
      <BackButton />
      <h1>Admin Dashboard</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
};

export default AdminDash;