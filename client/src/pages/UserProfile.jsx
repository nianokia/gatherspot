import { useContext } from "react";
import AuthContext from "../context/authContext.jsx";
import EditVendorProfile from "./EditVendorProfile.jsx";
import { BackButton } from "../constants/constant.jsx";

const UserProfile = () => {
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const roleId = user?.role_id;
  return (
    <div className="UserProfile">
      <BackButton />
      <h2>My Profile</h2>
      <ul className="profileDetails">
        <li>
          Name: {user?.f_name} {user?.l_name}
        </li>
        <li>
          Email: {user?.email}
        </li>
        <li>
          Phone: {user?.phone || "N/A"}
        </li>
        <li>
          User ID: {user?.id}
        </li>
        <li>
          Role: {user?.role}
        </li>
      </ul>
      {roleId === 3 && (
        <EditVendorProfile userId={user?.id} token={token} loading={loading} setLoading={setLoading} />
      )}
    </div>
  );
};

export default UserProfile;