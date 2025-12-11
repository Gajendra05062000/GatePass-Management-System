<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page language="java" import="java.util.*, gatepass.Database" %>
<%@ page import="java.sql.*,java.time.*,java.time.format.DateTimeFormatter,java.io.*,java.util.Base64,gatepass.CommonService"%>
<script>
    // **CRITICAL FIX:** Checks if this page is inside an iframe.
    // If it is, it forces the TOP-level window to redirect to the login page, 
    // breaking out of the frame structure.
    if (window.self !== window.top) {
        window.top.location.href = window.location.href;
    }
</script>

<%
    // ==========================================================
    // 🛡️ SECURITY HEADERS TO PREVENT CACHING THE DASHBOARD PAGE
    // Forces re-authentication when the user clicks the back button.
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache");    // HTTP 1.0.
    response.setDateHeader("Expires", 0);        // Proxies.
    
    // --- 1. INITIALIZE VARIABLES & SESSION CHECK ---
    String sessionUsername = (String) session.getAttribute("username");
    boolean sessionValid = (sessionUsername != null);
    boolean loginSuccess = sessionValid; // Assume success if session is already valid
    String errorMessage = null;
    
    // --- 2. LOGIN ATTEMPT PROCESSING ---
    // Only attempt login if session is NOT valid and form data is present
    if (!sessionValid) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String formSubmitted = request.getParameter("formSubmitted");
        
        if ("true".equals(formSubmitted) && username != null && password != null) {

             Connection conn1 = null;
             PreparedStatement ps1 = null; 
             ResultSet rs1 = null;
             
             try {
               // Assuming 'gatepass.Database' and its getConnection method are correct
               Database db = new Database();	
               conn1 = db.getConnection();
               
               // Use PreparedStatement for security (prevent SQL Injection)
               String sql = "SELECT PASSWORD FROM GATEPASSLOGIN WHERE USERNAME = ?";
               ps1 = conn1.prepareStatement(sql);
               ps1.setString(1, username);
               
               rs1 = ps1.executeQuery();

               if (rs1.next()) {
                   String storedPassword = rs1.getString("PASSWORD");
                   
                   if (storedPassword.equals(password)) {
                       // Authentication SUCCESS
                       loginSuccess = true;
                       session.setAttribute("username", username); 
                       session.setMaxInactiveInterval(30 * 60);
                       
                       // 🔄 PRG IMPLEMENTATION: Redirect to a safe GET request
                       // This replaces the dangerous POST request in the browser history.
                       response.sendRedirect("login.jsp");
                       return; // Crucial: Stop processing the current POST request
                   } 
               }
               
               if (!loginSuccess) {
                   // Authentication FAILED
                   errorMessage = "*Incorrect Username or Password"; 
               }
               
            } catch (SQLException e) { 
                errorMessage = "Database Error during login: " + e.getMessage();
                e.printStackTrace();
            } catch (Exception e) { 
                errorMessage = "System Error during login: " + e.getMessage();
                e.printStackTrace();
            } finally {
                // Close resources safely
                if (rs1 != null) try { rs1.close(); } catch (Exception e) {} 
                if (ps1 != null) try { ps1.close(); } catch (Exception e) {} 
                if (conn1 != null) try { conn1.close(); } catch (Exception e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Gate Pass <%= loginSuccess ? "Dashboard" : "Login" %></title>
<link rel="stylesheet" href="index2.css">
<script src="login.js"></script>

<style>
/* === GLOBAL RESET === */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* === BODY === */
html, body {
    height: 100%;
    /* Dashboard allows scrolling, Login prevents it */
    overflow-x: hidden; 
    overflow-y: <%= loginSuccess ? "auto" : "hidden" %>;
}

body {
    background-color: <%= loginSuccess ? "#f4f7f6" : "#fff" %>;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: <%= loginSuccess ? "flex-start" : "center" %>;
    min-height: 100vh;
}

.error-label {
    color: #c0392b; 
    font-size: 14px;
    font-weight: bold;
    margin-top: 15px; 
    padding: 8px;
    border: 1px solid #e74c3c;
    background-color: #fceae9; 
    border-radius: 5px;
}

/* === HEADER (Combined styles) === */
.header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 20px; 
    /* Using corporate colors for high-contrast professional look */
    background: <%= loginSuccess ? "linear-gradient(90deg, #1e3c72 0%, #2a5298 100%)" : "#303f9f" %>; 
    color: white;
    position: fixed;
    width: 100%;
    top: 0;
    z-index: 1000;
    box-shadow: 0 4px 15px rgba(0,0,0,0.3);
    height: 110px;
}

.logo {
    height: 80px;
    filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.2));
    transition: transform 0.2s;
    flex-shrink: 0; 
}
.logo:hover {
    cursor: pointer;
    transform: scale(1.05);
}

.center-text {
    text-align: center;
    flex: 1;
    padding: 0 20px;
}

.center-text h1 {
    font-size: <%= loginSuccess ? "30px" : "28px" %>;
    font-weight: bold;
    letter-spacing: 1px;
    margin-bottom: 5px;
    /* Ensure title is white in dashboard mode */
    color: <%= loginSuccess ? "#fff" : "inherit" %>; 
}

.center-text h2 {
    font-size: <%= loginSuccess ? "17px" : "18px" %>;
    font-weight: 500;
    opacity: 0.9;
    /* Ensure subtitle is accent color in dashboard mode */
    color: <%= loginSuccess ? "inherit" : "inherit" %>;
}

/* === LOGIN FORM STYLES (PRESERVED AS IS) === */
<% if (!loginSuccess) { %>
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: calc(100vh - 160px);
    width: 100%;
}

.login-form {
    background: #fff;
    border-radius: 15px;
    padding: 40px 50px;
    max-width: 420px;
    width: 90%;
    text-align: center;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
    animation: fadeIn 0.5s ease;
    margin-top: 120px;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}

.flash {
    animation: flash 1s linear infinite alternate;
}

@keyframes flash {
    from { color: #1e3c72; }
    to { color: #2ecc71; }
}
h1 {
    font-size: 22px;
    font-weight: bold;
    margin-top: 10px;
}

h2 {
    font-size: 16px;

    margin-bottom: 20px;
}
input[type="text"],
input[type="password"] {
    width: 100%;
    padding: 10px 12px;
    margin: 5px 0;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 15px;
    transition: 0.3s;
}

input[type="text"]:focus,
input[type="password"]:focus {
    border-color: #1e3c72;
    box-shadow: 0 0 6px rgba(30, 60, 114, 0.4);
    outline: none;
}

.button-container {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-top: 20px;
}

input[type="submit"],
input[type="reset"] {
    width: 45%;
    padding: 10px;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    color: #fff;
    font-weight: bold;
    cursor: pointer;
    transition: 0.3s ease;
}

input[type="submit"] {
    background-color: #1e3c72;
}

input[type="submit"]:hover {
    background-color: #344fa1;
}

input[type="reset"] {
    background-color: #c0392b;
}

input[type="reset"]:hover {
    background-color: #e74c3c;
}

.footer {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background-color: #303f9f;
    color: #fff;
    text-align: center;
    padding: 8px 0;
    font-size: 13px;
}
<% } %>

/* === DASHBOARD NAVBAR STYLES (IMPROVED AND MODERNIZED) === */
<% if (loginSuccess) { %>
.navbar {
    position: fixed;
    top: 110px;
    left: 0;
    width: 100%;
    height: 55px; /* Slightly taller for modern look */
    background: #ffffff; /* White navbar for clean contrast */
    border-bottom: 3px solid #007bff; /* Primary accent color line */
    box-shadow: 0 2px 5px rgba(0,0,0,0.15);
    z-index: 999;
    display: flex; 
    justify-content: space-between; 
}

.navbar ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
    display: flex;
    height: 100%;
}
.navbar ul li {
    display: block;
    position: relative;
    line-height: 55px; /* Adjusted line-height */
    text-align: center;
}
.navbar ul li a.main-link {
    display: block;
    padding: 0 20px;
    text-decoration: none;
    color: #1e3c72; /* Dark Navy text */
    font-weight: 600;
    transition: background-color 0.3s, color 0.3s;
    border-right: 1px solid #e9ecef; /* Subtle divider */
}
.navbar ul li:hover > a.main-link {
    background: #1e3c72; /* Dark Navy hover background */
    color: #ffffff;
}

.dropdown-content {
    display: none;
    position: absolute;
    top: 55px; /* Adjusted top alignment */
    left: 0;
    min-width: 260px; /* Slightly wider */
    background-color: #ffffff;
    box-shadow: 0 8px 16px 0 rgba(0,0,0,0.25);
    z-index: 1000;
    text-align: left;
    border: 1px solid #007bff;
    border-top: none;
    border-radius: 0 0 6px 6px;
    overflow: hidden;
}
.dropdown-content a {
    color: #333;
    padding: 0 10px;
    text-decoration: none;
    display: block;
    font-weight: 500;
    white-space: nowrap;
    border-bottom: 1px solid #f0f0f0;
    transition: background-color 0.2s, color 0.2s;
}
.dropdown-content a:hover {
    background-color: #e3f2fd;
    color: #1e3c72;
}
.navbar ul li:hover .dropdown-content {
    display: block;
}

.action-buttons-container {
    display: flex;
    align-items: center;
    padding: 0 15px; 
    height: 100%;
}

.action-button {
    color: white;
    border: none;
    padding: 8px 15px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    margin-left: 10px;
    transition: background-color 0.3s, transform 0.1s;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.change-password-button {
    background: #2ecc71; /* Green for key action */
}
.change-password-button:hover {
    background: #27ad60;
    transform: translateY(-1px);
}

.logout-button {
    background: #dc3545; /* Red for logout */
}
.logout-button:hover {
    background: #c82333;
    transform: translateY(-1px);
}

.main-content {
    position: fixed;
    top: 165px; /* 110px (Header) + 55px (Navbar) = 165px */
    left: 0;
    right: 0;
    bottom: 50px;
    background: #f8f9fa; /* Lighter background for content area */
    overflow: hidden;
    z-index: 500;
    padding: 10px; /* Padding for the iframe container */
}
.main-content iframe {
    width: 100%;
    height: 100%;
    border: 1px solid #e9ecef; /* Subtle border for the content frame */
    border-radius: 8px;
    background: white;
    box-shadow: 0 0 15px rgba(0,0,0,0.05);
}
<% } %>

/* === FOOTER (Combined styles) === */
.footer {
    display:flex;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: <%= loginSuccess ? "linear-gradient(90deg, #1e3c72 0%, #2a5298 100%)" : "#303f9f" %>;
    color: #fff;
    text-align: center;
    padding: 8px 0;
    font-size: 13px;
    align-items:center;
    justify-content:center;
    height: 50px;
    z-index: 1000;
    box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
}
.footer img{
      height: 34px;
      /* Adjust filter for better visibility on dark navy background */
      filter: drop-shadow(0 0 2px rgba(0,0,0,0.5)); 
    }

</style>

<script>
function confirmLogout() {
    if (confirm("Are you sure you want to log out of the Gate Pass Management System?")) {
        // Redirect to logout.jsp to destroy the session.
        window.top.location.href = 'logout.jsp'; 
    }
}
function changePassword() {
    const iframe = document.getElementsByName("right")[0];
    if (iframe) {
        iframe.src = 'change_password.jsp'; 
    } else {
        alert("Error: Main content frame not found.");
    }
}
</script>
</head>

<body onload="document.login?.username?.focus()">

<header class="header">
    <img src="logo1.png" class="logo" alt="NFL Logo" <%= loginSuccess ? "onclick=\"window.location.href='login.jsp';\"" : "" %>>
    <div class="center-text">
        <h1>CISF GATE PASS MANAGEMENT SYSTEM</h1>
        <h2>NATIONAL FERTILIZERS LIMITED, PANIPAT UNIT</h2>
    </div>
    <img src="logo2.png" class="logo" alt="CISF Logo"
    onclick="window.open('http://10.3.122.199/', '_blank');" />
</header>

<%
    // --- 3. CONDITIONAL DISPLAY LOGIC ---
    if (loginSuccess) {
        // Display Dashboard Content
%>
    <nav class="navbar">
        <ul>
        <li>
                <a href="login.jsp" class="main-link">🏠 Home</a>
            </li>
            <li>
                <a href="#" class="main-link">📝 Contract</a>
                <div class="dropdown-content">
                    <a href="Contract.jsp" target="right">Contract Registration</a>
                    <a href="Contract_History.jsp" target="right">Contract History</a>
                    <a href="UpdateContract.jsp" target="right">Update Contract Details</a>
                    <a href="contract_deposition.jsp" target="right">Deposit Contract</a>
                    
                </div>
            </li>
            
            <li>
                <a href="#" class="main-link">🚶 Visitor</a>
                <div class="dropdown-content">
                
                    <a href="visitor.jsp" target="right">Visitor Gatepass</a>
                    <a href="viewall.jsp" target="right">View All Visitors</a>
                    <a href="Revisit.jsp" target="right">Visitor Revisit</a>
                    <a href="viewbydate.jsp" target="right">View by Date</a>
                    <a href="viewbyname.jsp" target="right">View by Officer to Meet</a>
                    <a href="viewbystate.jsp" target="right">View by State</a>

                </div>
            </li>
            <li>
            	<a href="#" class="main-link">👷 Contract Labour/Trainee </a>
                <div class="dropdown-content">
                    <a href="ContractLabour.jsp" target="right">Contract Labour/Trainee Gate Pass</a>
                    <a href="ContractLabourHistory.jsp" target="right">Contract Labour/Traine Pass History</a>
                    <a href="labourpass_deposition.jsp" target="right">Deposit Contract Labour/Trainee Pass </a>
                </div>
            </li>
            <li>
                <a href="#" class="main-link">🌍 Foreigner</a>
                <div class="dropdown-content">
                    <a href="ForeignerGatepass.jsp" target="right">Foreigner Gate Pass</a>
                    <a href="ForeignerGatepassHistory.jsp" target="right">Foreigner Pass History</a>
                    <a href="Foreignpass_deposition.jsp" target="right">Deposit Foreigner Pass</a>
                </div>
            </li>
        </ul>
        
        <div class="action-buttons-container">
            <button class="action-button change-password-button" onclick="changePassword()">
                🔑 Change Password
            </button>
            <button class="action-button logout-button" onclick="confirmLogout()">
               🚪 Log Out
            </button>
        </div>
    </nav>

    <main class="main-content">
        <!-- Default page should be Welcome.jsp -->
        <iframe src="Welcome.jsp" name="right" scrolling="yes"></iframe>
    </main>
<%
    } else {
        // Display Login Form Content
%>
<div class="login-container">
    <div class="login-form">
        <form name="login" action="login.jsp" method="post"> 
            <input type="hidden" name="formSubmitted" value="true">
            <img src="logo1.png" alt="NFL Logo" height="160" width="150">
            <h1 class="flash">CISF GATEPASS MANAGEMENT SYSTEM</h1>
            <h2>NFL PANIPAT UNIT</h2>

            <div class="table-container">
                <table>
                    <tr>
                        <td><label for="username">Username:</label></td>
                        <td><input type="text" id="username" name="username" required></td>
                    </tr>
                    <tr>
                        <td><label for="password">Password:</label></td>
                        <td><input type="password" id="password" name="password" required></td>
                    </tr>
                </table>
            </div>

            <div class="button-container">
                <input type="submit" value="Login">
                <input type="reset" value="Cancel">
            </div>

            <%
                if (errorMessage != null) {
            %>
                <p class="error-label"><%= errorMessage %></p>
            <% } %>
        </form>
    </div>
</div>
<%
    } // End of Conditional Display
%>

<div class="footer">
    <% if (loginSuccess) { %>
        <img src="logo2.png" class="logo" alt="NFL Logo" onclick="window.open('http://10.3.122.199/', '_blank');">
        &nbsp;
    <% } %>
    <p>&copy; <%= java.time.Year.now() %>, IT Department NFL, Panipat</p>
</div>



</body>
</html>