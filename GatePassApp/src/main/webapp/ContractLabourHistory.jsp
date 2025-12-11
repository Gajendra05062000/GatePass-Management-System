<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
    // ==========================================================
    // SECURITY HEADERS
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // ==========================================================
    // LOGIN VALIDATION
    // ==========================================================
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%! 
    private static final String[] HEADERS = {
        "GatePass No.", "Photo", "Name", "Father Name", "Designation",
        "Age", "Local Address", "Identification Mark", "Validity Period",
        "Issue Date", "Action"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Contract Labour Register</title>

<style>
/* SAME DESIGN AS TEMPLATE */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f4f7f6;
    padding: 20px;
    color: #333;
}
img {
    display: block;
    max-width: 80px;
    height: 100px;
    object-fit: cover;
    border-radius: 4px;
}
h2 {
    color: #1e3c72;
    margin-bottom: 25px;
    text-align: center;
    text-transform: uppercase;
}
#searchInput {
    width: 97.5%;
    padding: 12px 20px;
    margin-bottom: 20px;
    border: 2px solid #ccc;
    border-radius: 8px;
    font-size: 16px;
}
#searchInput:focus { border-color: #007bff; }
.table-wrapper {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    border-radius: 8px;
    overflow: hidden;
}
#registerTable {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
}
#registerTable th {
    background-color: #1e3c72;
    color: white;
    padding: 12px 15px;
    text-align: left;
}
#registerTable td {
    border: 1px solid #ddd;
    padding: 10px 15px;
}
#registerTable tr:nth-child(even) td { background: #f9f9f9; }
#registerTable tr:hover td { background: #e0f7fa; }
#registerTable td a {  font-weight: 600; }
.btn-bar { text-align: center; margin-top: 25px; }
.btn {
    background: #007bff; color: #fff; border: none;
    padding: 10px 25px; border-radius: 6px;
    cursor: pointer; transition: .3s; margin: 0 10px;
}
.btn:hover { background: #0056b3; transform: scale(1.02); }
.error-message { color: red; text-align: center; padding: 20px; font-weight: bold; }
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

<script>
// Load print page
function loadPrintPageInMainFrame(srNo){
    const url = "PrintContractLabour.jsp?srNo=" + srNo;
    if (window.parent && window.parent.right) {
        window.parent.right.location.href = url;
    } else {
        console.error("Frame not found. Opening directly.");
        window.location.href = url;
    }
}

// Search function
function filterTable() {
    const filter = document.getElementById("searchInput").value.toUpperCase();
    const rows = document.querySelectorAll("#registerTable tbody tr");

    rows.forEach(row => {
        row.style.display = row.innerText.toUpperCase().includes(filter) ? "" : "none";
    });
}
</script>
</head>

<body onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode;}">

<div class="container">
    <h2>CONTRACT LABOUR REGISTER</h2>

    <input type="text" id="searchInput" onkeyup="filterTable()"
           placeholder="Search by Name, Father Name, Designation or anything...">

    <form action="saveContractLabourDetails" method="post" name="text_form" enctype="multipart/form-data">

        <div class="table-wrapper">
            <table id="registerTable">
                <thead>
                    <tr>
                        <% for (String h : HEADERS) { %>
                            <th><%= h %></th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>

                <%
                Connection conn = null;
                Statement st = null;
                ResultSet rs = null;
                int count = 0;
                SimpleDateFormat oracleFormat = new SimpleDateFormat("dd-MMM-yyyy"); // Updated to match Oracle format
                Date today = oracleFormat.parse(oracleFormat.format(new Date()));  // Ensure today's date is formatted correctly

                try {
                    Database db = new Database();
                    conn = db.getConnection();
                    st = conn.createStatement();

                    // SQL query to fetch data from the table
                    String query = "SELECT SER_NO, NAME, FATHER_NAME, DESIGNATION, AGE, LOCAL_ADDRESS, " +
                                   "IDENTIFICATION, TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE, " +
                                   "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VALIDITY_FROM, " +
                                   "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VALIDITY_TO, " +
                                   "TO_CHAR(VALIDITY_FROM,'DD-MM-YYYY') AS VALIDITY_FROM_STR, " +
                                   "TO_CHAR(VALIDITY_TO,'DD-MM-YYYY') AS VALIDITY_TO_STR, DEPOSITED " +
                                   "FROM GATEPASS_CONTRACT_LABOUR ORDER BY SER_NO DESC";

                    rs = st.executeQuery(query);

                    while (rs.next()) {
                        count++;

                        String vf = rs.getString("VALIDITY_FROM_STR");
                        String vt = rs.getString("VALIDITY_TO_STR");
                        String deposited = rs.getString("DEPOSITED");  // expecting 'Y' or 'N'

                        String status = "Expired";
                        String color = "style='color:red;font-weight:bold;'";

                        try {
                            if (vf != null && vt != null) {
                                // ===============================================================
                                // MULTI-FORMAT DATE PARSER (Fix for rows like SER_NO 6)
                                // ===============================================================
                                Date validityFrom = null;
                                Date validityTo = null;

                                String[] formats = {
                                    "dd-MM-yyyy",  // Format for date like 21-11-2025
                                    "dd-MM-yy",    // Format for date like 21-11-25
                                    "dd-MMM-yyyy", // Format for date like 21-NOV-2025 (this matches Oracle format)
                                    "dd-MMM-yy"    // Format for date like 21-NOV-25
                                };

                                for (String fmt : formats) {
                                    try {
                                        SimpleDateFormat f = new SimpleDateFormat(fmt);
                                        f.setLenient(false);  // Disable lenient parsing to avoid errors

                                        if (validityFrom == null) {
                                            validityFrom = f.parse(vf);
                                        }
                                        if (validityTo == null) {
                                            validityTo = f.parse(vt);
                                        }
                                    } catch (Exception e) {
                                        // ignore, try next format
                                    }
                                }

                                // If unable to parse → stop processing this row
                                if (validityFrom == null || validityTo == null) {
                                    status = "Invalid Date";
                                    color = "style='color:gray;font-weight:bold;'";
                                } else {
                                    // Now compare dates
                                    boolean isActive = (!today.before(validityFrom) && !today.after(validityTo));

                                    if (isActive) {
                                        // If within the validity range, check if gatepass is taken
                                        if (deposited != null && deposited.equalsIgnoreCase("Y")) {
                                            status = "Deposited";
                                            color = "style='color:orange;font-weight:bold;'";
                                        } else {
                                            status = "Active";
                                            color = "style='color:green;font-weight:bold;'";
                                        }
                                    } else {
                                        status = "Expired";
                                        color = "style='color:red;font-weight:bold;'";
                                    }
                                }
                            }
                        } catch (Exception e) {
                            System.out.println("Error: " + e);
                            status = "Error";
                            color = "style='color:gray;font-weight:bold;'";
                        }

                %>

                <tr>
                    <td>
                        NFL/CISF/LABOUR/0<%= rs.getInt("SER_NO") %>
                        <span <%= color %>> (<%= status %>) </span>
                    </td>

                    <td>
                        <a href="ShowImage.jsp?srNo=<%=rs.getInt("SER_NO")%>" target="_blank">
                            <img src="ShowImage.jsp?srNo=<%=rs.getInt("SER_NO")%>" alt="Photo">
                        </a>
                    </td>

                    <td><%= rs.getString("NAME") %></td>
                    <td><%= rs.getString("FATHER_NAME") %></td>
                    <td><%= rs.getString("DESIGNATION") %></td>
                    <td><%= rs.getString("AGE") %></td>
                    <td><%= rs.getString("LOCAL_ADDRESS") %></td>
                    <td><%= rs.getString("IDENTIFICATION") %></td>

                    <td><%= rs.getString("VALIDITY_FROM") %> to <%= rs.getString("VALIDITY_TO") %></td>
                    <td><%= rs.getString("ISSUE_DATE") %></td>

                    <td>
                        <a href="PrintContractLabour.jsp?srNo=<%=rs.getInt("SER_NO")%>" class="print-link">View Pass</a>
                    </td>
                </tr>

                <%
                        }
                        if (count == 0) {
                %>

                <tr>
                    <td colspan="<%= HEADERS.length %>" class="error-message">
                        No contract labour records found.
                    </td>
                </tr>

                <% 
                        }
                    } catch (Exception ex) {
                        out.println("<div class='error-message'>Error: " + ex.getMessage() + "</div>");
                        ex.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch(Exception e){}
                        if (st != null) try { st.close(); } catch(Exception e){}
                        if (conn != null) try { conn.close(); } catch(Exception e){}
                    }
                %>

                </tbody>
            </table>
        </div>

        <div class="btn-bar">
            <button type="button" class="btn" onclick="window.location.href='ContractLabour.jsp'">
                New Entry
            </button>

            <button type="button" class="btn" onclick="window.print();">
                Print Register
            </button>
        </div>

    </form>
</div>

</body>
</html>
