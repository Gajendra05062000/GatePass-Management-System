<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.Date"%>
<%
// ==========================================================
// 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
// ==========================================================
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
response.setDateHeader("Expires", 0); // Proxies.

// ==========================================================
// 🔑 SESSION AUTHENTICATION CHECK
// ==========================================================
// Check if the "username" session attribute exists (set during successful login)
if (session.getAttribute("username") == null) {
	// If not authenticated, redirect to the main login page
	response.sendRedirect("login.jsp");
	return; // Stop processing the rest of the page
}
%>

<%!// Define the column names for the table headers in a declaration block (available globally)
	private static final String[] HEADERS = {"Gatepass No.", "Photo", "Name", "Father Name", "Address", "Contact",
			"Date of Visit", "Time", "Officer to Meet", "Purpose", "Material", "Action"};
	// Define the date format mask for Oracle, matching the YYYY-MM-DD input
	private static final String DATE_FORMAT_MASK = "YYYY-MM-DD";%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Visitor Records by Date</title>

<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control"
	content="no-cache, no-store, must-revalidate">
<meta http-equiv="expires" content="0">

<style>
/* Base Styling */
body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background-color: #f4f7f6;
	padding: 20px;
	color: #333;
}

h3 {
	color: #1e3c72;
	text-align: center;
	margin-top: 10px;
	margin-bottom: 25px;
	text-transform: uppercase;
}

/* --- FORM STYLING --- */
#dateForm {
	background: #ffffff;
	max-width: 700px;
	margin: 0 auto 30px;
	padding: 20px;
	border-radius: 10px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.form-row {
	display: flex;
	gap: 20px;
	align-items: flex-end;
	justify-content: space-between;
}

.form-group {
	display: flex;
	flex-direction: column;
	flex-grow: 1;
}

.form-group label {
	font-size: 14px;
	color: #333;
	margin-bottom: 5px;
	font-weight: bold;
}

#dateForm input[type="date"] {
	padding: 10px 10px;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 15px;
	height: 40px;
	box-sizing: border-box;
}

#dateForm input[type="submit"] {
	background-color: #1e3c72;
	color: #fff;
	border: none;
	border-radius: 6px;
	cursor: pointer;
	transition: background 0.3s ease, transform 0.1s;
	font-size: 15px;
	font-weight: bold;
	height: 40px;
	padding: 0 20px;
	box-sizing: border-box;
	width: 150px;
}

#dateForm input[type="submit"]:hover {
	background-color: #0056b3;
	transform: scale(1.02);
}
/* --- END FORM STYLING --- */

/* --- TABLE & SEARCH STYLING --- */
#searchInput {
	width: 100%;
	padding: 12px 20px;
	margin-bottom: 20px;
	box-sizing: border-box;
	border: 2px solid #ccc;
	border-radius: 8px;
	font-size: 16px;
	transition: border-color 0.3s;
}

#searchInput:focus {
	border-color: #007bff;
	outline: none;
}

#visitorTable {
	border-collapse: collapse;
	width: 100%;
	margin-top: 20px;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
	border-radius: 8px;
	overflow: hidden;
	background-color: white;
}

#visitorTable th {
	background-color: #1e3c72;
	color: white;
	padding: 12px 15px;
	text-align: left;
	font-size: 15px;
	font-weight: bold;
	border: none;
}

#visitorTable td {
	border: 1px solid #ddd;
	padding: 10px 15px;
	text-align: left;
	font-size: 14px;
	background-color: #ffffff;
	color: #333;
}

#visitorTable tr:nth-child(even) td {
	background-color: #f9f9f9;
}

#visitorTable tr:hover td {
	background-color: #e0f7fa;
	cursor: default;
}

#visitorTable td a {
	color: #007bff;
	text-decoration: none;
	font-weight: 600;
}

#visitorTable td a:hover {
	text-decoration: underline;
}

img {
	display: block;
	max-width: 80px;
	height: 100px;
	object-fit: cover;
	border-radius: 4px;
}

.error-message {
	text-align: center;
	color: red;
	font-weight: bold;
	padding: 20px;
}
/* Custom Alert Box Styles */
.custom-alert {
	position: fixed;
	top: 20px;
	left: 50%;
	transform: translateX(-50%);
	z-index: 2000;
	padding: 15px 30px;
	border-radius: 8px;
	font-weight: bold;
	color: #fff;
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
	text-align: center;
	min-width: 300px;
	animation: slideDown 0.3s ease-out;
}

.custom-alert.error {
	background-color: #c0392b; /* Red */
	border: 1px solid #e74c3c;
}

.custom-alert.success {
	background-color: #27ae60; /* Green */
	border: 1px solid #2ecc71;
}

@
keyframes slideDown {from { top:-60px;
	opacity: 0;
}

to {
	top: 20px;
	opacity: 1;
}
}
</style>
</head>

<body>
	<%
	// 1. Get and define parameters
	String fromdate = request.getParameter("datum1");
	String todate = request.getParameter("datum");

	// Flag to check if the form has been submitted
	boolean formSubmitted = (fromdate != null && !fromdate.isEmpty() && todate != null && !todate.isEmpty());
	%>

	<script>
		// Placeholder function for messaging
		function showMessage(msg) {
			console.log("Validation Error: " + msg);
		}

		function displayCustomAlert(message, type) {
		    const alertBox = document.getElementById('customAlertBox');
		    
		    // Set message and class (error, success, info)
		    alertBox.innerHTML = message;
		    alertBox.className = 'custom-alert ' + type;
		    alertBox.style.display = 'block';

		    // Automatically hide after 4 seconds
		    setTimeout(() => {
		        alertBox.style.display = 'none';
		    }, 4000);
		}


		function ValidateForm2(form) {
		    const fromDateStr = form.datum1.value;
		    const toDateStr = form.datum.value;

		    if (fromDateStr === "" || toDateStr === "") {
		        const msg = "Please select both From Date and To Date.";
		        displayCustomAlert(msg, 'error');
		        return false;
		    }

		    // Convert date strings to Date objects for comparison
		    const fromDate = new Date(fromDateStr);
		    const toDate = new Date(toDateStr);

		    // Check if From Date is later than To Date
		    if (fromDate > toDate) {
		        const msg = "The 'From Date' cannot be later than the 'To Date'.";
		        displayCustomAlert(msg, 'error');
		        return false;
		    }
		    
		    return true; 
		}

		// Loads the visitor card into the main dashboard frame
		function loadPrintPageInMainFrame(visitorId) {
			const url = "print_visitor_card.jsp?id=" + visitorId;

			if (window.parent && window.parent.right) {
				window.parent.right.location.href = url;
			} else {
				window.location.href = url;
			}
		}

		// Search function must be placed outside the scriptlet block
		function filterTable() {
			var input, filter, table, tr, td, i, j, txtValue;
			input = document.getElementById("searchInput");
			filter = input.value.toUpperCase();
			table = document.getElementById("visitorTable");
			tr = table.getElementsByTagName("tr");

			for (i = 1; i < tr.length; i++) {
				var rowMatch = false;
				td = tr[i].getElementsByTagName("td");
				for (j = 0; j < td.length; j++) {
					if (td[j]) {
						txtValue = td[j].textContent || td[j].innerText;
						if (txtValue.toUpperCase().indexOf(filter) > -1) {
							rowMatch = true;
							break;
						}
					}
				}

				if (rowMatch) {
					tr[i].style.display = "";
				} else {
					tr[i].style.display = "none";
				}
			}
		}
	</script>
	<h3>📅 View Visitor Records by Date</h3>

	<form name="datelogin" method="get"
		action="<%=request.getRequestURI()%>" id="dateForm"
		onsubmit="return ValidateForm2(this)">
		<div id="customAlertBox" style="display: none;" class="custom-alert"></div>
		<div class="form-row">

			<div class="form-group">
				<label for="datum1">From Date:</label> <input type="date"
					name="datum1" id="datum1" required
					value="<%=formSubmitted ? fromdate : ""%>">
			</div>

			<div class="form-group">
				<label for="datum">To Date:</label> <input type="date" name="datum"
					id="datum" required value="<%=formSubmitted ? todate : ""%>">
			</div>

			<div class="form-group" style="flex-grow: 0;">
				<input type="submit" name="view" value="View Records">
			</div>
		</div>
	</form>

	<%
	// STEP 2: CHECK SUBMISSION AND RENDER RESULTS (Only if formSubmitted is true)
	if (formSubmitted) {
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;

		try {
			// 2. Establish connection
			gatepass.Database db = new gatepass.Database();
			conn = db.getConnection();

			// 3. SQL QUERY: Selecting all required fields
			String sql = "SELECT ID, NAME, FATHERNAME, ADDRESS, DISTRICT, STATE, PINCODE, PHONE, "
			+ "TO_CHAR(ENTRYDATE, 'DD-MON-YYYY') AS ENTRYDATE, TIME, OFFICERTOMEET, PURPOSE, MATERIAL "
			+ "FROM visitor WHERE entrydate BETWEEN TO_DATE(?, ?) AND TO_DATE(?, ?) ORDER BY id DESC";

			ps = conn.prepareStatement(sql);

			// Set parameters for the Prepared Statement
			ps.setString(1, fromdate);
			ps.setString(2, DATE_FORMAT_MASK);
			ps.setString(3, todate);
			ps.setString(4, DATE_FORMAT_MASK);

			// 4. Execute Query
			rs = ps.executeQuery();
	%>

	<hr style="border-top: 2px solid #ccc;">

	<h3>Visitor Records Summary</h3>

	<input type="text" id="searchInput" onkeyup="filterTable()"
		placeholder="Search by name, ID, contact, officer, or purpose...">

	<TABLE id="visitorTable" cellpadding="0" cellspacing="0">
		<thead>
			<TR>
				<%
				for (String header : HEADERS) {
				%>
				<th><%=header%></th>
				<%
				}
				%>
			</TR>
		</thead>
		<tbody>

			<%
			// 5. Process Results
			int rowCount = 0;
			while (rs.next()) {
				rowCount++;
			%>

			<TR>
				<td>NFL/CISF/VISITOR/0<%=rs.getString("id")%></td>
				<td><a href="ShowVisitor.jsp?id=<%=rs.getString("id")%>"
					target="_blank"> <img
						src="ShowVisitor.jsp?id=<%=rs.getString("id")%>"
						alt="Visitor Photo" />
				</a></td>

				<TD><%=rs.getString("NAME") != null ? rs.getString("NAME").toUpperCase() : ""%></TD>
				<td><%=rs.getString("FATHERNAME")%></td>
				<TD><%=rs.getString("ADDRESS")%><br> <%=rs.getString("DISTRICT")%>,
					<%=rs.getString("STATE")%> - <%=rs.getString("PINCODE")%></TD>

				<TD><%=rs.getString("PHONE")%></TD>
				<TD><%=rs.getString("ENTRYDATE")%></TD>
				<TD><%=rs.getString("TIME")%></TD>

				<TD><%=rs.getString("OFFICERTOMEET")%></TD>
				<TD><%=rs.getString("PURPOSE")%></TD>
				<TD><%=rs.getString("MATERIAL")%></TD>
				<td><a href="javascript:void(0);"
					onclick="loadPrintPageInMainFrame('<%=rs.getString("id")%>');">
						View pass </a></td>
			</TR>

			<%
			} // end while loop
			%>

			<%
			if (rowCount == 0) {
			%>
			<tr>
				<td colspan="<%=HEADERS.length%>" class="error-message">No
					records found for the selected date range.</td>
			</tr>
			<%
			}
			%>
		</tbody>
	</TABLE>

	<%
	} catch (SQLException ex) {
	System.err.println("SQL Error: " + ex.getMessage());
	out.println("<div class='error-message'>Database Error (" + ex.getErrorCode() + "): " + ex.getMessage() + "</div>");
	} catch (Exception ex) {
	System.err.println("General Error: " + ex.getMessage());
	out.println("<div class='error-message'>A general error occurred: " + ex.getMessage() + "</div>");
	} finally {
	// 6. Resource Cleanup (Crucial!)
	if (rs != null)
		try {
			rs.close();
		} catch (SQLException ignore) {
		}
	if (ps != null)
		try {
			ps.close();
		} catch (SQLException ignore) {
		}
	if (conn != null)
		try {
			conn.close();
		} catch (SQLException ignore) {
		}
	}
	} // end if (formSubmitted)
	%>
</body>
</html>