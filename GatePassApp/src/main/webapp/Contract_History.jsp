<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, gatepass.Database"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
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
    // Check if the "username" session attribute exists (set during successful login)
    if (session.getAttribute("username") == null) {
        // If not authenticated, redirect to the main login page
        response.sendRedirect("login.jsp");
        return; // Stop processing the rest of the page
    }
%>
<%!// Define the column names for the table headers
	private static final String[] HEADERS = {"Contract No.", "Contract Name", "Contractor", "Department",
			"Validity (From)", "Validity (To)", "Reg. No.", "Action"};%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Contract Registration History</title>

<style>
/* Base Styling */
body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background-color: #f4f7f6;
	padding: 20px;
	color: #333;
}

h2 {
	color: #1e3c72;
	margin-bottom: 25px;
	text-align: center;
	text-transform: uppercase;
}

/* Search Bar Styling */
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

img {
	display: block;
	max-width: 80px;
	height: 100px;
	object-fit: cover;
	border-radius: 4px;
}

/* Professional Table Styling */
#contractTable {
	border-collapse: collapse;
	width: 100%;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
	border-radius: 8px;
	overflow: hidden;
	background-color: white;
}

#contractTable th {
	background-color: #1e3c72; /* Darker, primary header color */
	color: white;
	padding: 12px 15px;
	text-align: left;
	font-size: 15px;
	font-weight: bold;
}

#contractTable td {
	border: 1px solid #ddd; /* Light separator lines */
	padding: 10px 15px;
	text-align: left;
	font-size: 14px;
}

#contractTable tr:nth-child(even) td {
	background-color: #f9f9f9; /* Subtle striping */
}

#contractTable tr:hover td {
	background-color: #e0f7fa; /* Highlight row on hover */
	cursor: default;
}

#contractTable td a {

	text-decoration: none;
	font-weight: 600;
}

#contractTable td a:hover {
	text-decoration: underline;
}

.action-cell {
	text-align: center;
	width: 100px;
}

.error-message {
	text-align: center;
	color: red;
	font-weight: bold;
	padding: 20px;
}
.print-link {
	text-decoration: none;
	color: #fff;
	background: #007bff;
	padding: 6px 10px;
	border-radius: 4px;
	font-size: 13px;
	white-space: nowrap;
	transition: background-color 0.3s;
}

.print-link:hover {
	background: #0056b3;
}
</style>
</head>
<body>

	<h2>Contract Registration History</h2>

	<!-- SEARCH OPTION -->
	<input type="text" id="searchInput" onkeyup="filterTable()"
		placeholder="Search by ID, Name, Contractor, or Department...">

	<table id="contractTable" cellpadding="0" cellspacing="0">
		<thead>
			<tr>
				<%
				for (String header : HEADERS) {
				%>
				<th><%=header%></th>
				<%
				}
				%>
			</tr>
		</thead>
		<tbody>

			<%
			Connection conn = null;
			Statement st = null;
			ResultSet rs = null;
			int rowCount = 0;
			// Proper Oracle date format
            SimpleDateFormat oracleFormat = new SimpleDateFormat("dd-MMM-yyyy");
            Date today = oracleFormat.parse(oracleFormat.format(new Date()));

			try {
				Database db = new Database();
				conn = db.getConnection();
				st = conn.createStatement();

				// Fetch contracts, order by ID descending (most recent first)
				String query = "SELECT ID, CONTRACT_NAME, CONTRACTOR_NAME, DEPARTMENT, "
				+ "TO_CHAR(VALIDITY_FROM, 'DD-MON-YYYY') AS V_FROM, "
				+ "TO_CHAR(VALIDITY_TO, 'DD-MON-YYYY') AS V_TO, " + "REGISTRATION, DEPOSITED "
				+ "FROM GATEPASS_CONTRACT ORDER BY ID DESC";

				rs = st.executeQuery(query);

				// 5. Process Results
				while (rs.next()) {
					rowCount++;
					String contractId = rs.getString("ID");
					String vf = rs.getString("V_FROM");
                    String vt = rs.getString("V_TO");
                    String deposited = rs.getString("DEPOSITED");   // New column
                    String status = "Expired";
                    String color = "style='color:red;font-weight:bold;'";

                    try {
                        if (vf != null && vt != null) {
                            Date from = oracleFormat.parse(vf);
                            Date to   = oracleFormat.parse(vt);

                            if (!today.before(from) && !today.after(to)) {
                            	if (deposited=="Y" || deposited=="y") {
                                    // Gatepass taken
                                    status = "Gatepass Taken";
                                    color = "style='color:orange;font-weight:bold;'";
                                } else {
                                    // Normal Active
                                    status = "Active";
                                    color = "style='color:green;font-weight:bold;'";
                                }
                            }
                            else {
                                // Expired (regardless of deposited)
                                status = "Expired";
                                color = "style='color:red;font-weight:bold;'";
                            }
                        }
                    } catch (Exception ignore) {}
			%>

			<tr data-id="<%=contractId%>">
				<td>NFL/CISF/CONTRACT/0<%=contractId%><span <%= color %>> (<%= status %>) </span></td>
				<td><%=rs.getString("CONTRACT_NAME")%></td>
				<td><%=rs.getString("CONTRACTOR_NAME")%></td>
				<td><%=rs.getString("DEPARTMENT")%></td>
				<td><%=rs.getString("V_FROM")%></td>
				<td><%=rs.getString("V_TO")%></td>
				<td><%=rs.getString("REGISTRATION")%></td>
				<td class="action-cell"><a class="print-link"
					href="PrintContract.jsp?id=<%=contractId%>"
					onclick="return printPagePopUp(this.href);"> View Contract </a></td>
			</tr>

			<%
			} // end while loop
			%>

			<%
			if (rowCount == 0) {
			%>
			<tr>
				<td colspan="<%=HEADERS.length%>" class="error-message">No
					contract records found.</td>
			</tr>
			<%
			}
			%>
		</tbody>
	</table>

	<%
	} catch (SQLException e) {
	out.println("<div class='error-message'>Database Error: " + e.getMessage() + "</div>");
	} catch (Exception e) {
	out.println("<div class='error-message'>General Error: " + e.getMessage() + "</div>");
	} finally {
	// 6. Resource Cleanup (Crucial!)
	if (rs != null)
		try {
			rs.close();
		} catch (SQLException ignore) {
		}
	if (st != null)
		try {
			st.close();
		} catch (SQLException ignore) {
		}
	if (conn != null)
		try {
			conn.close();
		} catch (SQLException ignore) {
		}
	}
	%>

	<!-- JAVASCRIPT FOR SEARCH FILTER -->
	<script>
		function filterTable() {
			var input, filter, table, tr, td, i, j, txtValue;
			input = document.getElementById("searchInput");
			filter = input.value.toUpperCase();
			table = document.getElementById("contractTable");
			tr = table.getElementsByTagName("tr");

			// Start loop from tr[1] to skip the <thead> row
			for (i = 1; i < tr.length; i++) {
				var rowMatch = false;
				// Get all cells (td) in the current row
				td = tr[i].getElementsByTagName("td");

				// Loop through all cells in the current row
				for (j = 0; j < td.length; j++) {
					if (td[j]) {
						// Extract text value from the cell
						txtValue = td[j].textContent || td[j].innerText;

						// Check if the cell content matches the filter
						if (txtValue.toUpperCase().indexOf(filter) > -1) {
							rowMatch = true;
							break; // Stop checking cells in this row once a match is found
						}
					}
				}

				// Show or hide the row based on whether a match was found
				if (rowMatch) {
					tr[i].style.display = "";
				} else {
					tr[i].style.display = "none";
				}
			}
		}
		function loadPrintPageInMainFrame(ID) {
			const url = "PrintContract.jsp?srNo=" + ID;

			// Check if the parent window has a frame/iframe named 'right'
			if (window.parent && window.parent.right) {
				window.parent.right.location.href = url;
			} else {
				// Fallback if not inside the frame structure
				alert("Could not load the print page in the main content frame. Loading in current window.");
				window.location.href = url;
			}
		}
	</script>

</body>
</html>