<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page import="java.sql.*" %>
<%@page import="java.lang.*" %>
<%@page import="gatepass.Database" %>
<%@page import="java.io.*" %>
<%@ page import="java.util.Base64" %>

<%
    // ==========================================================
    // 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache");    // HTTP 1.0.
    response.setDateHeader("Expires", 0);        // Proxies.

    // ==========================================================
    // 🔑 SESSION AUTHENTICATION CHECK
    // ==========================================================
    if (session.getAttribute("username") == null) {
        // Fix: Use JavaScript to redirect the parent frame if session is invalid
%>
        <script>
            if (window.self !== window.top) {
                window.top.location.href = 'login.jsp';
            } else {
                window.location.href = 'login.jsp';
            }
        </script>
<%
        return; 
    }
%>

<%
// Get current date and time for dynamic display
LocalDateTime now = LocalDateTime.now();
DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy");
DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");
String currentDate = now.format(dateFormatter);
String currentTime = now.format(timeFormatter);

// --- Initialization ---
int VisitorsToday = 0;
int TotalVisitors = 0;
int TodayContractLabour = 0;
int TotalContractLabour = 0;
int TodayContract = 0;
int ActiveContract = 0;
int TodayForeigner = 0;
int ActiveForeigner = 0;

// Date format for SQL comparison (Ensuring matching date masks)
DateTimeFormatter sqlDateFormatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
String todayDateString = now.format(DateTimeFormatter.ofPattern("dd-MM-yyyy"));

String sqlTodayCondition =
    "TO_CHAR(ENTRYDATE, 'DD-MM-yyyy') = '" + todayDateString + "'";

String sqlTodayConditionUpdate =
    "TO_CHAR(UPDATE_DATE, 'DD-MM-yyyy') = '" + todayDateString + "'";


Connection conn = null;
Statement st = null;
ResultSet rs = null;

try {
    Database db = new Database();
    conn = db.getConnection();
    st = conn.createStatement();

    // 1. VISITORS
    rs = st.executeQuery("SELECT Count(ID) FROM VISITOR WHERE " + sqlTodayCondition);
    if (rs.next()) {
        VisitorsToday = rs.getInt(1);
    }
    if (rs != null) rs.close(); 
    
    rs = st.executeQuery("SELECT Count(ID) FROM VISITOR");
    if (rs.next()) {
        TotalVisitors = rs.getInt(1);
    }
    if (rs != null) rs.close();

    // 2. CONTRACT LABOUR
    rs = st.executeQuery("SELECT Count(SER_NO) FROM GATEPASS_CONTRACT_LABOUR WHERE " + sqlTodayConditionUpdate);
    if (rs.next()) {
        TodayContractLabour = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
    rs = st.executeQuery("SELECT COUNT(SER_NO) FROM GATEPASS_CONTRACT_LABOUR");
    if (rs.next()) {
        TotalContractLabour = rs.getInt(1);
    }
    if (rs != null) rs.close();

    // 3. CONTRACT REGISTRATION
    rs = st.executeQuery("SELECT Count(ID) FROM GATEPASS_CONTRACT WHERE " + sqlTodayConditionUpdate);
    if (rs.next()) {
        TodayContract = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
    rs = st.executeQuery("SELECT Count(ID) FROM GATEPASS_CONTRACT");
    if (rs.next()) {
        ActiveContract = rs.getInt(1);
    }
    if (rs != null) rs.close();

    // 4. FOREIGNER PASS
    rs = st.executeQuery("SELECT Count(SER_NO) FROM GATEPASS_FOREIGNER WHERE " + sqlTodayConditionUpdate);
    if (rs.next()) {
        TodayForeigner = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
    rs = st.executeQuery("SELECT Count(SER_NO) FROM GATEPASS_FOREIGNER");
    if (rs.next()) {
        ActiveForeigner = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
} catch (SQLException e) {
    System.err.println("Database Error on Dashboard Load: " + e.getMessage());
} catch (Exception e) {
    System.err.println("General Error on Dashboard Load: " + e.getMessage());
} finally {
    // Crucial: Resource Cleanup
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (st != null) try { st.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Welcome Dashboard</title>
<style>
/* Added Font Import for better typography */
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap');

:root {
    /* Updated Colors for a modern, professional look */
    --primary-navy: #1e3c72;
    --accent-blue: #0056b3; /* Darker Blue */
    --accent-green: #27ae60; /* Deeper Green */
    --accent-red: #c0392b; /* Deeper Red */
    --accent-orange: #d35400; /* Deeper Orange */
    --background-light: #f4f7f6; /* Very light subtle gray */
    --card-shadow: 0 5px 15px rgba(0, 0, 0, 0.1); /* Slightly softer shadow */
    --text-dark: #2c3e50;
    --text-muted: #7f8c8d;
}

body {
    font-family: 'Poppins', sans-serif;
    background-color: var(--background-light);
    padding: 20px;
    color: var(--text-dark);
    margin: 0;
}

.dashboard-container {
    max-width: 1250px;
    margin: auto;
}

/* --- Welcome Banner --- */
.welcome-banner {
    background: linear-gradient(135deg, var(--primary-navy) 0%, #2980b9 100%); /* Diagonal gradient */
    color: white;
    padding: 30px 40px;
    border-radius: 15px;
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
    margin-bottom: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: relative;
    overflow: hidden; /* For pseudo-element background effect */
}

/* Subtle background pattern */
.welcome-banner::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%2334579c' fill-opacity='0.1'%3E%3Cpath d='M36 34L30 30.91V34h6zm6 0l-6-3.09V34h6zM24 34v-3.09L18 34h6zm6 0v-3.09L24 34h6zm-12 0v-3.09L6 34h6zm6 0v-3.09L12 34h6zm-12-6l6 3.09V28H6zm6 0l-6 3.09V28h6zm-6-6l6 3.09V22H6zm6 0l-6 3.09V22h6zm12 0l6 3.09V22h-6zm-6 0l-6 3.09V22h6zm-6-6l6 3.09V16H6zm6 0l-6 3.09V16h6zm-6-6l6 3.09V10H6zm6 0l-6 3.09V10h6zm12 0l6 3.09V10h-6zm-6 0l-6 3.09V10h6zm-6-6l6 3.09V4H6zm6 0l-6 3.09V4h6zm12 0l6 3.09V4h-6zm-6 0l-6 3.09V4h6zm12 0l6 3.09V4h-6zM36 4l6 3.09V4h-6zm6 0l-6 3.09V4h6zM36 10l6 3.09V10h-6zm6 0l-6 3.09V10h6zM36 16l6 3.09V16h-6zm6 0l-6 3.09V16h6zM36 22l6 3.09V22h-6zm6 0l-6 3.09V22h6zM36 28l6 3.09V28h-6zm6 0l-6 3.09V28h6zM36 34l6 3.09V34h-6zM36 40l-6-3.09V40h6zm-6 0l-6-3.09V40h6zM24 40v-3.09L18 40h6zm6 0v-3.09L24 40h6zM12 40v-3.09L6 40h6zm6 0v-3.09L12 40h6zm-12-6l6 3.09V34H6zm6 0l-6 3.09V34h6zM6 28l6 3.09V28H6zm6 0l-6 3.09V28h6zm-6-6l6 3.09V22H6zm6 0l-6 3.09V22h6zM36 40l6 3.09V40h-6zM42 40l-6 3.09V40h6zM36 34l6 3.09V34h-6zM42 34l-6 3.09V34h6zM36 28l6 3.09V28h-6zM42 28l-6 3.09V28h6zM36 22l6 3.09V22h-6zM42 22l-6 3.09V22h6zM36 16l6 3.09V16h-6zM42 16l-6 3.09V16h6zM36 10l6 3.09V10h-6zM42 10l-6 3.09V10h6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
    opacity: 0.15;
    z-index: 1;
}
.welcome-banner * {
    z-index: 2; /* Ensure text is above the pattern */
}

.welcome-banner h1 {
    font-size: 32px; /* Larger title */
    font-weight: 700;
    margin: 0;
}

.welcome-banner p {
    font-size: 16px; /* Slightly larger subtitle */
    opacity: 0.9;
    margin-top: 5px;
    font-weight: 300;
}

.date-time {
    text-align: right;
    font-size: 16px;
    font-weight: 400;
}
.date-time .time {
    font-size: 24px;
    font-weight: 600;
    display: block;
    animation: pulse 1.5s infinite; /* Subtle animation */
}
@keyframes pulse {
    0% { color: #ffffff; }
    50% { color: #ecf0f1; }
    100% { color: #ffffff; }
}


/* --- Key Stats Cards --- */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); /* Wider minimum card size */
    gap: 25px;
    margin-bottom: 30px;
}

.stat-card {
    background-color: white;
    padding: 0; /* Remove padding here */
    border-radius: 12px;
    box-shadow: var(--card-shadow);
    border-left: 6px solid; /* Thicker left border */
    overflow: hidden;
}

/* Link Wrapper for Card Interaction */
.stat-card a {
    text-decoration: none;
    color: inherit;
    display: block;
    padding: 20px; /* Apply padding inside the link */
    cursor: pointer;
    transition: transform 0.3s ease-out, box-shadow 0.3s ease-out;
}

.stat-card a:hover {
    transform: translateY(-8px); /* Lifts the card more aggressively */
    box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
    background-color: #fcfcfc; /* Very subtle background change on hover */
}

.stat-card-data {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
}

.stat-card-data:first-child {
    border-bottom: 1px solid #ecf0f1; /* Cleaner divider */
    margin-bottom: 10px;
}
.stat-card-data:last-child {
    padding-bottom: 0;
}


.stat-card.red { border-color: var(--accent-red); }
.stat-card.blue { border-color: var(--accent-blue); }
.stat-card.green { border-color: var(--accent-green); }
.stat-card.orange { border-color: var(--accent-orange); }

.stat-card .value {
    font-size: 25px;
    font-weight: 700;
    color: var(--primary-navy);
    line-height: 1; /* Tighter spacing */
}

.stat-card .label {
    font-size: 13px;
    color: var(--text-muted);
    font-weight: 500;
    text-transform: uppercase;
}

/* --- Quick Actions and Guide --- */
.content-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 25px;
}

.section-header {
    font-size: 24px;
    font-weight: 700;
    color: var(--primary-navy);
    margin-bottom: 20px;
    padding-bottom: 5px;
    display: flex;
    align-items: center;
}
.section-header span {
    margin-right: 10px;
    color: var(--accent-blue);
}

.quick-actions-box, .system-guide-box {
    background-color: white;
    padding: 25px;
    border-radius: 12px;
    box-shadow: var(--card-shadow);
    transition: box-shadow 0.3s;
}
.quick-actions-box:hover, .system-guide-box:hover {
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

/* Quick Action Buttons */
.action-buttons {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); /* More flexible grid */
    gap: 15px;
}
.action-button {
    display: flex;
    flex-direction: column; /* Stack icon and text */
    align-items: center;
    justify-content: center;
    padding: 20px 10px;
    height: 100px; /* Uniform height */
    border-radius: 8px;
    font-weight: 600;
    text-decoration: none;
    color: white;
    transition: transform 0.2s, box-shadow 0.2s, opacity 0.2s;
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    font-size: 14px;
    text-align: center;
}
.action-button:hover {
    transform: scale(1.05); /* Zoom effect */
    opacity: 1;
}
.action-button span {
    font-size: 28px; /* Larger icon */
    margin-bottom: 5px;
}

.btn-visitor { background-color: #3498db; } /* Light Blue */
.btn-contract { background-color: var(--primary-navy); }
.btn-foreigner { background-color: #e67e22; } /* Carrot Orange */
.btn-contract-reg { background-color: var(--accent-green); } 
.btn-history { background-color: #9b59b6; } /* Amethyst */
.btn-support { background-color: #7f8c8d; } /* Gray */

/* System Guide */
.system-guide-box ul {
    list-style: none;
    padding: 0;
}
.system-guide-box li {
    padding: 12px 15px;
    border-radius: 6px;
    font-size: 15px;
    color: var(--text-dark);
    cursor: pointer;
    transition: background-color 0.2s, color 0.2s;
    margin-bottom: 8px;
    border-left: 3px solid transparent;
}
.system-guide-box li:hover {
    background-color: #ecf0f1;
    color: var(--accent-blue);
    border-left: 3px solid var(--accent-blue);
}
.system-guide-box li span {
    margin-right: 10px;
    font-size: 18px;
}


@media (max-width: 1024px) {
    .content-grid {
        grid-template-columns: 1fr;
    }
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
@media (max-width: 600px) {
    .welcome-banner {
        flex-direction: column;
        align-items: flex-start;
    }
    .date-time {
        margin-top: 15px;
        text-align: left;
    }
    .stats-grid {
        grid-template-columns: 1fr;
    }
    .action-buttons {
        grid-template-columns: 1fr;
    }
}
</style>

<script>
    // Function to load links into the right iframe (main content area)
    function loadContent(url) {
        // Find the iframe named 'right' in the parent window
        const iframe = window.parent.document.getElementsByName('right')[0];
        if (iframe) {
            iframe.src = url;
        } else {
            console.error("Iframe 'right' not found. Falling back to current window.");
            window.location.href = url; // Fallback
        }
    }
    
    // Function to update time dynamically
    function updateTime() {
        const timeElement = document.getElementById('current-time');
        if (timeElement) {
            const now = new Date();
            const options = { hour: '2-digit', minute: '2-digit', hour12: true };
            const timeString = now.toLocaleTimeString('en-IN', options).replace(/ /g, '');
            timeElement.textContent = timeString;
        }
    }

    // Initialize time update
    window.onload = function() {
        updateTime();
        setInterval(updateTime, 1000); // Update every second
    };
</script>


</head>
<body>

<div class="dashboard-container">

<div class="welcome-banner">
    <div>
        <h1>Welcome, CISF GATE PASS!</h1>
        <p>Your centralized dashboard for NFL Panipat Unit.</p>
    </div>
    <div class="date-time">
        <span id="current-time" class="time"><%= currentTime %></span>
        <span class="date"><%= currentDate %></span>
    </div>
</div>

<div class="stats-grid">
    
    <div class="stat-card red">
        <a href="javascript:loadContent('visitor_today.jsp');">
            <div class="stat-card-data">
                <div class="value"><%= VisitorsToday %></div>
                <div class="label">Visitor Pass Issued Today</div>
            </div>
        </a>
        
        <a href="javascript:loadContent('viewall.jsp');">
            <div class="stat-card-data">
                 <div class="value"><%= TotalVisitors %></div>
                <div class="label">Total Registered Visitor</div>
            </div>
        </a>
    </div>
    
    <div class="stat-card blue">
        <a href="javascript:loadContent('contract_labour_today.jsp');">
            <div class="stat-card-data">
                 <div class="value"><%= TodayContractLabour %></div>
                <div class="label">Labour/Trainee Issued Today</div>
            </div>
            </a>
            <a href="javascript:loadContent('ContractLabourHistory.jsp');">
            <div class="stat-card-data">
                <div class="value"><%= TotalContractLabour %></div>
                <div class="label">Total Registered Labour/Trainee</div>
            </div>
        </a>
    </div>
    
    <div class="stat-card green">
        <a href="javascript:loadContent('Contract_today.jsp');">
            <div class="stat-card-data">
                 <div class="value"><%= TodayContract %></div>
                <div class="label">Contracts Registered Today</div>
            </div>
            </a>
            <a href="javascript:loadContent('Contract_History.jsp');">
            <div class="stat-card-data">
                <div class="value"><%= ActiveContract %></div>
                <div class="label">Total Registered Contracts</div>
            </div>
        </a>
    </div>
    
    <div class="stat-card orange">
        <a href="javascript:loadContent('Foreigner_today.jsp');">
           <div class="stat-card-data">
                 <div class="value"><%= TodayForeigner %></div>
                <div class="label">Foreigner Pass Issued Today</div>
            </div>
            </a>
            <a href="javascript:loadContent('ForeignerGatepassHistory.jsp');">
            <div class="stat-card-data">
                <div class="value"><%= ActiveForeigner %></div>
                <div class="label">Total Registered Foreigner</div>
            </div>
        </a>
    </div>
</div>

<div class="content-grid">
    <div class="quick-actions-box">
        <h2 class="section-header"><span>&#128640;</span> Quick Actions</h2>
        <div class="action-buttons">
            <a href="javascript:loadContent('visitor.jsp');" class="action-button btn-visitor">
                <span>🚶</span> New Visitor Pass
            </a>
            <a href="javascript:loadContent('ContractLabour.jsp');" class="action-button btn-contract">
                <span>👷</span> Labour/Trainee Pass
            </a>
            <a href="javascript:loadContent('ForeignerGatepass.jsp');" class="action-button btn-foreigner">
                <span>&#127760;</span> Foreigner Pass
            </a>
            <a href="javascript:loadContent('Contract.jsp');" class="action-button btn-contract-reg">
                <span>&#128196;</span> Contract Registration
            </a>
            <a href="javascript:loadContent('viewall.jsp');" class="action-button btn-history">
                <span>&#128203;</span> Visitor History
            </a>
            <a href="javascript:loadContent('Report Technical Issues.jsp');" class="action-button btn-support">
                <span>&#9881;</span> Technical Support
            </a>
        </div>
    </div>
    
    <div class="system-guide-box">
        <h2 class="section-header"><span>&#128214;</span> System Guide</h2>
        <ul>
            <li onclick="loadContent('viewbydate.jsp')"><span>&#128197;</span> Review Visitors by Date</li>
            <li onclick="loadContent('Contract_History.jsp')"><span>&#128274;</span> Check Contract Validity</li>
            <li onclick="loadContent('ForeignerGatepassHistory.jsp')"><span>&#128269;</span> Search Foreigner Records</li>
            <li onclick="loadContent('change_password.jsp')"><span>&#128273;</span> Update User Credentials</li>
            <li onclick="loadContent('viewbyname.jsp')"><span>&#128101;</span> View Visitors by Officer</li>
        </ul>
    </div>
</div>


</div>

</body>
</html>