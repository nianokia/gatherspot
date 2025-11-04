import { useState, useEffect, useContext } from "react";
import { useParams } from "react-router";
import AuthContext from "../context/authContext.jsx";
import { getEventMetrics, getTicketSales, getAttendence, getRevenue, getNoShow } from "../api/eventMetrics.jsx";
import { fetchEventById } from "../api/event.jsx";
import { BackButton } from "../constants/constant";

const AnalyticsDash = () => {
  const { user, token, loading, setLoading } = useContext(AuthContext);
  const { eventId } = useParams();
  const [metrics, setMetrics] = useState({});
  const [totalTicketsSold, setTotalTicketsSold] = useState(0);
  const [totalRevenue, setTotalRevenue] = useState(0.00);
  const [attendanceCount, setAttendanceCount] = useState(0);
  const [noShowCount, setNoShowCount] = useState(0);
  const [event, setEvent] = useState(null);

  // ---------- FETCH EVENT DETAILS ----------
  const fetchEventDetails = async (eventId, token) => {
    try {
      const eventData = await fetchEventById(eventId, token);
      console.log("Fetched Event Data:", eventData.event);
      setEvent(eventData.event);
    } catch (error) {
      console.error("Error fetching event details:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (eventId && token) {
      fetchEventDetails(eventId, token);
    }
  }, [eventId, token]);

  // ---------- FETCH METRICS ----------
  const fetchMetrics = async (eventId, token) => {
    try {
      const eventMetrics = await getEventMetrics(eventId, token);
      setMetrics(eventMetrics);

      const ticketSales = await getTicketSales(eventId, token);
      setTotalTicketsSold(ticketSales.total_tickets_sold || 0);

      const revenueData = await getRevenue(eventId, token);
      setTotalRevenue(parseFloat(revenueData.total_revenue) || 0.00);

      const attendanceData = await getAttendence(eventId, token);
      setAttendanceCount(attendanceData.attendance_count || 0);

      const noShowData = await getNoShow(eventId, token);
      setNoShowCount(noShowData.no_show_count || 0);
    } catch (error) {
      console.error("Error fetching analytics metrics:", error);
    }
  };

  // For demonstration, you might call fetchMetrics with hardcoded values
  // In a real app, you would get eventId and token from context or props
  useEffect(() => {
    fetchMetrics(eventId, token);
  }, []);

  // ---------- CONDITIONAL RENDERING ----------
  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <BackButton />
      <h1>"{event?.title}" Analytics & Reporting</h1>
      <hr />
      <div>
        <h2>Event Metrics</h2>
        <p>Total Tickets Sold: {totalTicketsSold}</p>
        <p>Total Revenue: ${totalRevenue.toFixed(2)}</p>
        <p>Attendance Count: {attendanceCount}</p>
        <p>No-Show Count: {noShowCount}</p>
      </div>
    </div>
  );
};

export default AnalyticsDash;

{/* <ul className='userEventList'>
  <li>Clickable Events
    <ul>
      <li className='userEvent'>GET event_metrics</li>
      <li className="userEvent">GET feedback</li>
      <li className="userEvent">EXPORT report as a file</li>
    </ul>
  </li>
</ul> */}

  //  event_id: {
  //     type: DataTypes.UUID,
  //     allowNull: false,
  //     references: { model: 'events', key: 'id' },
  //     onDelete: 'CASCADE',
  // },
  // total_tickets_sold: {
  //     type: DataTypes.INTEGER,
  //     defaultValue: 0,
  // },
  // total_revenue: {
  //     type: DataTypes.DECIMAL(10, 2),
  //     defaultValue: 0.00,
  // },
  // attendance_count: {
  //     type: DataTypes.INTEGER,
  //     defaultValue: 0,
  // },
  // no_show_count: {
  //     type: DataTypes.INTEGER,
  //     defaultValue: 0,