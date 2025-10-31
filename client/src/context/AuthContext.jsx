import { useState, useEffect, createContext } from "react";
import { useNavigate } from "react-router";

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(false);

  // ------ Load user & token from localStorage when app mounts ------
  useEffect(() => {
    const storedUser = JSON.parse(localStorage.getItem("user"));
    const storedToken = localStorage.getItem("token");

    // --- If found, set their states ---
    if (storedUser && storedToken) {
      setUser(storedUser);
      setToken(storedToken);
    }

    // --- Set loading to false after initial load ---
    setLoading(false);
  }, []);

  // ------ If user & token exist, set localStorage items ------
  // ------ If not, remove them ------
  useEffect(() => {
    user ? localStorage.setItem("user", JSON.stringify(user)) : localStorage.removeItem("user");
    token ? localStorage.setItem("token", token) : localStorage.removeItem("token");
  }, [user, token]);

  // ---------- LOGIN FUNCTION: sets user & token ----------
  const login = (userData, jwtToken) => {
    localStorage.setItem("user", JSON.stringify(userData));
    localStorage.setItem("token", jwtToken);
    setUser(userData);
    setToken(jwtToken);
  };

  // ---------- LOGOUT FUNCTION: clears user & token ----------
  const logout = () => {
    localStorage.removeItem("user");
    localStorage.removeItem("token");
    setUser(null);
    setToken(null);
    navigate("/");
  };

  return (
    <AuthContext.Provider value={{ user, setUser, token, setToken, loading, setLoading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export default AuthContext;