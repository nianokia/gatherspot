import { useContext } from "react";
import AuthContext from "../context/authContext";
import AllEvents from "../components/AllEvents";
import AuthHub from "../components/AuthHub";

const StartPage = () => {
  const { user } = useContext(AuthContext);
  return (
    <div className="AppContainer">
      {user ? (
        <div>
          {/* --- DISPLAY ALL EVENTS --- */}
          <AllEvents />
        </div>
      ) : (
        <>
          <h1>Welcome to GatherSpot!</h1>
          <h2>Your one-stop spot for planning, organizing, and finding events.</h2>
          <h3>Get started by creating an account or logging in.</h3>
          <AuthHub />
        </>
      )}
    </div>
  )
}

export default StartPage;