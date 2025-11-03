import { useState, useEffect, useContext } from 'react';
import AuthContext from '../context/authContext.jsx';
import { fetchAllVendors, fetchEventsByVendorId } from '../api/vendor.jsx';

const VendorDash = () => {
  const { user, token, logout } = useContext(AuthContext);
  const [vendor, setVendor] = useState(null);
  const vendorId = vendor?.id;
  const [vendorEvents, setVendorEvents] = useState([]);

  console.log("Token: ", token);

  // ---------- LOAD VENDOR EVENTS ----------
  const loadVendorEvents = async () => {
    try {
      const data = await fetchEventsByVendorId(vendorId, token);
      console.log('Vendor Events:', data.events);

      // --- events array is located in data.events ---
      setVendorEvents(data.events);
    } catch (error) {
      console.error('Error fetching vendor events:', error);
    }
  };

  // ---------- GET VENDOR ----------
  const getVendor = async () => {
    const allVendors = await fetchAllVendors(token);
    // --- find vendor among all vendors ---
    const foundVendor = allVendors.vendors.find(v => v.user_id === user.id);
    setVendor(foundVendor);
  }

  // --- call getVendor whenever user or token changes ---
  useEffect(() => {
    getVendor();
  }, [user, token]);

  // --- call loadVendorEvents whenever vendor or token changes ---
  useEffect(() => {
    if (vendor && vendor.id) {
      loadVendorEvents();
    }
  }, [vendor, token]);

  return (
    <div className="VendorDash">
      <h1>Vendor Dashboard</h1>
      <hr />
      <h2>My Events</h2>

      {vendorEvents.length === 0 ? (
        <p>No events associated with this vendor.</p>
      ) : (
        <ul className="vendorEventsList">
          {/* --- ensure all keys are unique (event-UUID) --- */}
          {vendorEvents.map((event) => (
            <li key={`event-${event.id}`} value={event.id} className="singleEvent" onClick={() => navigate(`/${event.id}`)}>
              <div className="listHeader">
                <h3>{event.title}</h3>
              </div>
              <ul>
                <div className="singleEventListGroup">
                  <li>Event Type: {event.event_type}</li><li>Capacity: {event.capacity}</li>
                </div>
                <li>{event.description}</li>
                <div className="singleEventListGroup venueDateBlock">
                  <div className="venueBlock">
                    <li>
                      <ul>
                        <li>{event.venue ? event.venue.name : 'N/A'}</li>
                        <li>{event.venue ? event.venue.address : 'N/A'}</li>
                        <li>{event.venue ? event.venue.city : 'N/A'}, {" "}
                          {event.venue ? event.venue.state : 'N/A'}, {" "}
                          {event.venue ? event.venue.country : 'N/A'}, {" "}
                          {event.venue ? event.venue.zip_code : 'N/A'}
                        </li>
                      </ul>
                    </li>
                    <li>Venue Capacity: {event.venue ? event.venue.capacity : 'N/A'}</li>
                  </div>
                  <div className="dateBlock">
                    <li>Start Date: {formatDate(event.start_date)}</li>
                    <li>End Date: {formatDate(event.end_date)}</li>
                  </div>
                </div>
              </ul>
            </li>
          ))}
        </ul>
      )}
      <br />
      <button className='logoutBtn' onClick={logout}>Logout</button>
    </div>
  );
};

export default VendorDash;