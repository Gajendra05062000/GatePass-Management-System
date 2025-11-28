<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.Date"%>

<%!// Define the column names for the table headers
	private static final String[] HEADERS = {"Visitor ID", "Photo", "Name", "Father Name", "Address", "Contact",
			"Date of Visit", "Time", "Purpose", "Material", "Action"};%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Visitor Records by Officer</title>

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

/* --- FORM STYLING (Modernized) --- */
#officerForm {
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

#officerForm select {
	padding: 10px 10px;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 15px;
	height: 40px;
	box-sizing: border-box;
	width: 100%;
}

#officerForm input[type="submit"] {
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

#officerForm input[type="submit"]:hover {
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
</style>
</head>

<body>
	<%
	// 1. Get and define parameter
	String selectedOfficer = request.getParameter("officertomeet");

	// Flag to check if the result table should be rendered
	boolean showResults = (selectedOfficer != null && !selectedOfficer.isEmpty());

	// ----------------------
	// JavaScript Functions
	// ----------------------
	%>
	<script>
		function ValidateOfficerForm(form) {
			if (form.officertomeet.value === "") {
				alert("Please select an Officer to meet.");
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

		// Search function for the results table
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

	<h3>👥 Select the Officer to View Visitor Records</h3>

	<form name="selectOfficerForm" method="get"
		action="<%=request.getRequestURI()%>" id="officerForm"
		onsubmit="return ValidateOfficerForm(this)">
		<div class="form-row">
			<div class="form-group">
				<label for="officertomeet">Officer to Meet:</label> <select
					name="officertomeet" id="officertomeet" required>
					<option value=""
						<%=(selectedOfficer == null || selectedOfficer.isEmpty()) ? "selected" : ""%>
						disabled>-- Select Officer --</option>
					<%
					Connection conn = null;
					Statement st = null;
					ResultSet rs = null;
					try {
						Database db = new Database();
						conn = db.getConnection();

						if (conn != null) {
							String sql = "SELECT officers FROM officertomeet ORDER BY officers ASC";
							st = conn.createStatement();
							rs = st.executeQuery(sql);

							while (rs.next()) {
						String officerName = rs.getString("officers");
					%>
					<option value="<%=officerName%>"
						<%=officerName.equals(selectedOfficer) ? "selected" : ""%>><%=officerName%></option>
					<%
					}
					}
					} catch (SQLException e) {
					out.println("<option value='' disabled>⚠️ Error loading officers: " + e.getMessage() + "</option>");
					} finally {
					try {
					if (rs != null)
					rs.close();
					} catch (SQLException ignore) {
					}
					try {
					if (st != null)
					st.close();
					} catch (SQLException ignore) {
					}
					/* Do NOT close conn here if you plan to reuse it below. If you want separate connections, close it. 
					 * For robustness, it's safer to use a new connection for the result query. */
					// try { if (conn != null) conn.close(); } catch (SQLException ignore) {} 
					}
					%>
				</select>
			</div>

			<div class="form-group" style="flex-grow: 0;">
				<input type="submit" value="View Records">
			</div>
		</div>
	</form>

	<%
	// === 2. RESULTS TABLE (Rendered only if officer is selected) ===
	if (showResults) {
		Connection conn2 = null;
		Statement st2 = null;
		ResultSet rs2 = null;

		try {
			// Use a new connection object for the results query
			Database db2 = new Database();
			conn2 = db2.getConnection();

			// Query visitors for the selected officer
			// Note: Using descriptive column names where possible to fix original index-based access
			String sql = "SELECT ID, NAME, FATHERNAME, ADDRESS, DISTRICT, STATE, PINCODE, PHONE, "
			+ "TO_CHAR(ENTRYDATE, 'DD-MON-YYYY') AS ENTRYDATE, TIME, OFFICERTOMEET, PURPOSE, MATERIAL "
			+ "FROM visitor WHERE OFFICERTOMEET = '" + selectedOfficer + "' ORDER BY id DESC";

			st2 = conn2.createStatement();
			rs2 = st2.executeQuery(sql);
	%>

	<hr style="border-top: 2px solid #ccc;">

	<h3>
		Visitor Records for
		<%=selectedOfficer%></h3>

	<input type="text" id="searchInput" onkeyup="filterTable()"
		placeholder="Search by name, ID, contact, purpose, or material...">

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
			int rowCount = 0;
			while (rs2.next()) {
				rowCount++;
			%>

			<TR>
				<td><%=rs2.getString("ID")%></td>

				<td><a href="ShowVisitor.jsp?id=<%=rs2.getString("ID")%>"
					target="_blank"> <img
						src="ShowVisitor.jsp?id=<%=rs2.getString("ID")%>"
						alt="Visitor Photo" />
				</a></td>

				<TD><%=rs2.getString("NAME") != null ? rs2.getString("NAME").toUpperCase() : ""%></TD>
				<td><%=rs2.getString("FATHERNAME")%></td>

				<TD><%=rs2.getString("ADDRESS")%><br> <%=rs2.getString("DISTRICT")%>,
					<%=rs2.getString("STATE")%> - <%=rs2.getString("PINCODE")%></TD>

				<TD><%=rs2.getString("PHONE")%></TD>
				<TD><%=rs2.getString("ENTRYDATE")%></TD>
				<TD><%=rs2.getString("TIME")%></TD>

				<TD><%=rs2.getString("PURPOSE")%></TD>
				<TD><%=rs2.getString("MATERIAL")%></TD>

				<td><a href="javascript:void(0);"
					onclick="loadPrintPageInMainFrame('<%=rs2.getString("ID")%>');">
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
					records found for the selected officer.</td>
			</tr>
			<%
			}
			%>
		</tbody>
	</TABLE>

	<%
	} catch (SQLException ex) {
	System.err.println("SQL Error: " + ex.getMessage());
	out.println("<div class='error-message'>Database Error: " + ex.getMessage() + "</div>");
	} catch (Exception ex) {
	System.err.println("General Error: " + ex.getMessage());
	out.println("<div class='error-message'>A general error occurred: " + ex.getMessage() + "</div>");
	} finally {
	// 6. Resource Cleanup
	if (rs2 != null)
		try {
			rs2.close();
		} catch (SQLException ignore) {
		}
	if (st2 != null)
		try {
			st2.close();
		} catch (SQLException ignore) {
		}
	if (conn2 != null)
		try {
			conn2.close();
		} catch (SQLException ignore) {
		}
	}
	} // end if (showResults)
	%>
</body>
</html>