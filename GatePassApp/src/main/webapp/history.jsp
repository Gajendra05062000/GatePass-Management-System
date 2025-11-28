<%@ page import="java.sql.*, java.io.*"%>
<%@ page language="java" import="gatepass.Database"%>
<%
// ==========================================================
// 🚨 SECURITY HEADERS TO PREVENT CACHING THIS PAGE
// ==========================================================
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
response.setDateHeader("Expires", 0); // Proxies.

// ==========================================================
// 🔒 SESSION AUTHENTICATION CHECK
// ==========================================================
if (session.getAttribute("username") == null) {
	response.sendRedirect("login.jsp");
	return;
}
%>
<html>
<head>
<title>Visitor Details - Table View</title>
<style>
/* ... (Existing CSS styles remain the same) ... */

/* Pagination Style */
.pagination {
	text-align: center;
	padding: 20px 0;
}

.pagination a {
	color: #1e3c72;
	padding: 8px 16px;
	text-decoration: none;
	transition: background-color 0.3s;
	border: 1px solid #ddd;
	margin: 0 4px;
	border-radius: 4px;
}

.pagination a.active {
	background-color: #1e3c72;
	color: white;
	border: 1px solid #1e3c72;
}

.pagination a:hover:not(.active) {
	background-color: #ddd;
}

.pagination a.disabled {
	color: #ccc;
	pointer-events: none;
	cursor: default;
}

.current-page-info {
	color: #6c757d;
	margin: 0 15px;
	font-weight: bold;
}

/* ... (Existing table and search CSS) ... */
body {
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f8f9fa;
	margin: 0;
	padding: 20px;
}

h2 {
	text-align: center;
	color: #1e3c72;
	margin-bottom: 25px;
	text-transform: uppercase;
	letter-spacing: 1px;
	font-weight: 700;
}

/* 🔍 Search Bar */
.search-container {
	text-align: center;
	margin-bottom: 25px;
}

.search-bar {
	width: 90%;
	max-width: 600px;
	padding: 10px 15px;
	border: 1px solid #ced4da;
	border-radius: 25px;
	font-size: 15px;
	outline: none;
	transition: 0.3s;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.search-bar:focus {
	border-color: #007bff;
	box-shadow: 0 0 8px rgba(0, 123, 255, 0.2);
}

/* Table Styling */
.table-wrapper {
	background: #fff;
	border-radius: 12px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
	overflow-x: auto; /* Ensures responsiveness on small screens */
}

.visitor-table {
	width: 100%;
	border-collapse: collapse;
}

.visitor-table th, .visitor-table td {
	padding: 12px 15px;
	text-align: left;
	border-bottom: 1px solid #eee;
}

.visitor-table th {
	background-color: #1e3c72;
	color: #fff;
	font-weight: 600;
	text-transform: uppercase;
	font-size: 13px;
	white-space: nowrap;
}

.visitor-table tr:hover td {
	background-color: #f0f4ff;
}

.visitor-table tr:nth-child(even) {
	background-color: #f9f9f9;
}

.id-cell {
	font-weight: bold;
	color: #1e3c72;
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

/* ❌ No Results Message */
#noResults {
	display: none;
	text-align: center;
	color: #888;
	font-size: 16px;
	margin-top: 20px;
}

img {
	Display: block;
	max-width: 80px;
	height: 100px;
	object-fit: cover;
	border-radius: 4px;
}
</style>
</head>
<body>

	<%
	// --- PAGINATION PARAMETERS ---
	
	// --- SEARCH PARAMETER ---
String search = request.getParameter("search");
if (search == null) search = "";
search = search.trim();

// --- PAGINATION PARAMETERS ---
final int RECORDS_PER_PAGE = 100;
int currentPage = 1;

	

	
	// Ensure current page is at least 1
	if (currentPage < 1) {
		currentPage = 1;
	}
	
	// --- DATABASE VARIABLES ---
	Connection conn = null;
	Statement st = null;
	ResultSet rs = null;
	int totalRecords = 0;
	boolean recordsFound = false;

	try {
		// The file originally referenced gatepass.Database. I'll instantiate it here.
		gatepass.Database db = new gatepass.Database();
		conn = db.getConnection();
		st = conn.createStatement();
		
		// --- 1. Get Total Record Count (Needed for pagination links) ---
		String countQuery =
    "SELECT COUNT(*) FROM visitor "
  + "WHERE TRUNC(ENTRYDATE) = TRUNC(SYSDATE) AND ( "
  + " LOWER(NAME) LIKE LOWER('%" + search + "%') "
  + " OR LOWER(OFFICERTOMEET) LIKE LOWER('%" + search + "%') "
  + " OR LOWER(PURPOSE) LIKE LOWER('%" + search + "%') "
  + " OR LOWER(PHONE) LIKE LOWER('%" + search + "%') "
  + " OR TO_CHAR(ID) LIKE '%" + search + "%' "
  + ")";


		ResultSet rsCount = st.executeQuery(countQuery);
		if (rsCount.next()) {
			totalRecords = rsCount.getInt(1);
		}
		rsCount.close();
		
		// Calculate total pages
		int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);

		// Adjust current page if it exceeds total pages
		if (currentPage > totalPages && totalPages > 0) {
			currentPage = totalPages;
		}
        
        // Calculate the starting and ending row indexes based on the adjusted page
	    /* int startRow = (currentPage - 1) * RECORDS_PER_PAGE + 1;
        int endRow = currentPage * RECORDS_PER_PAGE; */
		
		// --- 2. Fetch Paginated Records using Oracle 11g ROWNUM ---
		/*
		 * ORACLE 11g PAGINATION PATTERN:
		 * SELECT * FROM (
		 * SELECT t.*, ROWNUM rn FROM (
		 * SELECT ID, NAME, ... FROM visitor ORDER BY id DESC 
		 * ) t
		 * ) WHERE rn BETWEEN [startRow] AND [endRow]
		 */
		/* String dataQuery = String.format(
			"SELECT * FROM ( " +
			"    SELECT t.*, ROWNUM rn FROM ( " +
			"        SELECT ID, NAME, FATHERNAME, AGE, ADDRESS, DISTRICT, STATE, PINCODE, PHONE, ENTRYDATE, TIME, OFFICERTOMEET, PURPOSE, MATERIAL, VEHICLE, DEPARTMENT " +
			"        FROM visitor ORDER BY id DESC" +
			"    ) t " +
			") WHERE rn BETWEEN %d AND %d",
			startRow, endRow
		);
		rs = st.executeQuery(dataQuery); */
		int startRow = (currentPage - 1) * RECORDS_PER_PAGE + 1;
		int endRow   = currentPage * RECORDS_PER_PAGE;



		String dataQuery =
			    "SELECT * FROM ( "
			  + "   SELECT inner_data.*, ROWNUM rn FROM ( "
			  + "       SELECT ID, NAME, FATHERNAME, AGE, ADDRESS, DISTRICT, STATE, PINCODE, "
			  + "              PHONE, TO_CHAR(ENTRYDATE,'DD-MON-YYYY') AS ENTRYDAT, ENTRYDATE, "
			  + "              \"TIME\", OFFICERTOMEET, PURPOSE, MATERIAL, VEHICLE, DEPARTMENT "
			  + "       FROM visitor "
			  + "       WHERE TRUNC(ENTRYDATE) = TRUNC(SYSDATE) "
			  + "         AND ( "
			  + "              LOWER(NAME) LIKE LOWER('%" + search + "%') "
			  + "           OR LOWER(OFFICERTOMEET) LIKE LOWER('%" + search + "%') "
			  + "           OR LOWER(PURPOSE) LIKE LOWER('%" + search + "%') "
			  + "           OR LOWER(PHONE) LIKE LOWER('%" + search + "%') "
			  + "           OR TO_CHAR(ID) LIKE '%" + search + "%' "
			  + "         ) "
			  + "       ORDER BY ENTRYDATE DESC, \"TIME\" DESC "
			  + "   ) inner_data "
			  + "   WHERE ROWNUM <= " + endRow
			  + ") WHERE rn >= " + startRow;




		rs = st.executeQuery(dataQuery);
		
	%>

	<h2>All Visitor Records (Page <%=currentPage%> of <%=totalPages%>)</h2>

	<div class="search-container">
    <form method="get">
        <input type="text" name="search" class="search-bar"
               placeholder="Search all records..."
               value="<%= search %>">
        <button type="submit" style="display:none;"></button>
        <input type="hidden" name="page" value="1">
    </form>
</div>


	<div class="table-wrapper">
		<table class="visitor-table" id="visitorTable">
			<thead>
				<tr>
					<th>Gatepass No.</th>
					<th>PHOTO</th>
					<th>Name</th>
					<th>Officer to Meet</th>
					<th>Purpose</th>
					<th>Date / Time</th>
					<th>Contact</th>
					<th>Address (District/State)</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody id="visitorTableBody">

				<%
				while (rs.next()) {
					recordsFound = true;
				%>

				<tr class="search-row">
					<td class="id-cell">NFL/CISF/VISITOR/0<%=rs.getInt("ID")%></td>
					<td><a href="ShowVisitor.jsp?id=<%=rs.getString("ID")%>"
						target="_blank"> <img
							src="ShowVisitor.jsp?id=<%=rs.getString("ID")%>"
							alt="Visitor Photo" />
					</a></td>
					<td><%=rs.getString("NAME")%><br> <small
						style="color: #6c757d;">(<%=rs.getString("FATHERNAME")%>,
							Age: <%=rs.getString("AGE")%>)
					</small></td>
					<td><%=rs.getString("OFFICERTOMEET")%><br>
					<small style="color: #6c757d;">(<%=rs.getString("DEPARTMENT")%>)
					</small></td>
					<td><%=rs.getString("PURPOSE")%></td>
					<td><%=rs.getString("ENTRYDAT")%><br> <small
						style="color: #6c757d;">@ <%=rs.getString("TIME")%></small></td>
					<td><%=rs.getString("PHONE")%><br> <small
						style="color: #6c757d;">Vehicle: <%=rs.getString("VEHICLE")%></small>
					</td>
					<td><%=rs.getString("ADDRESS")%>, <%=rs.getString("DISTRICT")%>,
						<%=rs.getString("STATE")%> - <%=rs.getString("PINCODE")%></td>
					<td ><a href="print_visitor_card.jsp?id=<%=rs.getInt("ID")%>"
						class="print-link" >View Pass</a></td>
					
				</tr>

				<%
				} // End while loop
				%>
			</tbody>
		</table>
	</div>

	<div class="pagination">
		<%
		if (totalPages > 1) {
			// Previous Page Link
			if (currentPage > 1) {
		%>
				<a href="?page=<%=currentPage - 1%>">Previous</a>
		<%
			} else {
		%>
				<a href="#" class="disabled">Previous</a>
		<%
			}

			// Page Number Links (Showing a reasonable range, e.g., current, previous 2, next 2)
			int startPage = Math.max(1, currentPage - 2);
			int endPage = Math.min(totalPages, currentPage + 2);
			
			if (startPage > 1) {
				out.println("<a href='?page=1'>1</a>");
				if (startPage > 2) out.println("<span>...</span>");
			}

			for (int i = startPage; i <= endPage; i++) {
				if (i == currentPage) {
		%>
					<a href="#" class="active"><%=i%></a>
		<%
				} else {
		%>
					<a href="?page=<%=i%>"><%=i%></a>
		<%
				}
			}
			
			if (endPage < totalPages) {
				if (endPage < totalPages - 1) out.println("<span>...</span>");
				out.println("<a href='?page=" + totalPages + "'>" + totalPages + "</a>");
			}

			// Next Page Link
			if (currentPage < totalPages) {
		%>
				<a href="?page=<%=currentPage + 1%>">Next</a>
		<%
			} else {
		%>
				<a href="#" class="disabled">Next</a>
		<%
			}
		}
		%>
	</div>
	
	<p class="current-page-info">Total Records: <%=totalRecords%></p>


	<%
	} catch (Exception ex) {
	// Output an error message to the user/console if connection fails
	out.println("<p style='color: #dc3545; text-align: center;'>Database Error: " + ex.getMessage() + "</p>");
	ex.printStackTrace();
	} finally {
	// Resource Cleanup: Ensures safe resource release
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

	<p id="noResults"
		style="<%=recordsFound ? "display: none;" : "display: block;"%>">
		<%
		if (totalRecords == 0) {
			out.print("No visitor records found in the database.");
		} else {
			out.print("No records found on this page.");
		}
		%>
	</p>


	

</body>
</html>