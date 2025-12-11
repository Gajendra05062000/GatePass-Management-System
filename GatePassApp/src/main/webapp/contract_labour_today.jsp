<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
    // ============================
    // SECURITY
    // ============================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // ============================
    // LOGIN CHECK
    // ============================
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%! 
    private static final String[] HEADERS = {
        "GatePass No.", "Photo", "Name", "Father Name", "Designation",
        "Age", "Local Address", "Identification Mark", "Validity Period",
        "Issue Date", "Status", "Action"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Contract Labour Register – Today</title>

<style>
/* SAME DESIGN AS VISITOR HISTORY PAGE */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f4f7f6;
    padding: 20px;
}
h2 {
    color: #1e3c72;
    margin-bottom: 20px;
    text-align: center;
    text-transform: uppercase;
}
#searchInput {
    width: 97%;
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
table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
}
th {
    background-color: #1e3c72;
    color: white;
    padding: 12px;
    font-size: 13px;
    text-transform: uppercase;
}
td {
    border: 1px solid #ddd;
    padding: 10px;
}
tr:nth-child(even) td { background: #f9f9f9; }
tr:hover td { background: #e0f7fa; }

img {
    max-width: 80px;
    height: 100px;
    object-fit: cover;
    border-radius: 4px;
}

.print-link {
	text-decoration: none;
	color: #fff;
	background: #007bff;
	padding: 6px 10px;
	border-radius: 4px;
	font-size: 13px;
	transition: .3s;
}
.print-link:hover { background: #0056b3; }

.error-message {
    text-align: center;
    color: red;
    font-weight: bold;
    padding: 20px;
}
</style>

<script>
function filterTable() {
    const filter = document.getElementById("searchInput").value.toUpperCase();
    const rows = document.querySelectorAll("#registerTable tbody tr");

    rows.forEach(row => {
        row.style.display = row.innerText.toUpperCase().includes(filter) ? "" : "none";
    });
}
</script>

</head>
<body>

<h2>Contract Labour Registered Today</h2>

<input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search...">

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

// Today’s date (for status check)
SimpleDateFormat df = new SimpleDateFormat("dd-MMM-yyyy");
Date today = df.parse(df.format(new Date()));

try {
    Database db = new Database();
    conn = db.getConnection();
    st = conn.createStatement();

    // ================================
    // TODAY ONLY RECORDS
    // ================================
    String sql =
        "SELECT SER_NO, NAME, FATHER_NAME, DESIGNATION, AGE, LOCAL_ADDRESS, IDENTIFICATION, "
      + "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VF_STR, "
      + "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VT_STR, "
      + "VALIDITY_FROM AS VF_DATE, VALIDITY_TO AS VT_DATE, "
      + "TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE, "
      + "DEPOSITED "
      + "FROM GATEPASS_CONTRACT_LABOUR "
      + "WHERE TRUNC(UPDATE_DATE)=TRUNC(SYSDATE) "
      + "ORDER BY SER_NO DESC";

    rs = st.executeQuery(sql);

    while (rs.next()) {
        count++;

        Date vfrom = rs.getDate("VF_DATE");
        Date vto   = rs.getDate("VT_DATE");
        String deposited = rs.getString("DEPOSITED");

        String status = "Invalid";
        String color  = "style='color:gray;font-weight:bold;'";

        if (vfrom != null && vto != null) {
            boolean isActive = (!today.before(vfrom) && !today.after(vto));

            if (isActive) {
                if ("Y".equalsIgnoreCase(deposited)) {
                    status = "Depositted";
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
%>

<tr>
    <td>NFL/CISF/LABOUR/0<%= rs.getInt("SER_NO") %></td>

    <td>
        <img src="ShowImage.jsp?srNo=<%=rs.getInt("SER_NO")%>" alt="Photo">
    </td>

    <td><%= rs.getString("NAME") %></td>
    <td><%= rs.getString("FATHER_NAME") %></td>
    <td><%= rs.getString("DESIGNATION") %></td>
    <td><%= rs.getString("AGE") %></td>
    <td><%= rs.getString("LOCAL_ADDRESS") %></td>
    <td><%= rs.getString("IDENTIFICATION") %></td>

    <td><%= rs.getString("VF_STR") %> to <%= rs.getString("VT_STR") %></td>
    <td><%= rs.getString("ISSUE_DATE") %></td>

    <td><span <%=color%>><%=status%></span></td>

    <td>
        <a href="PrintContractLabour.jsp?srNo=<%= rs.getInt("SER_NO") %>" 
           target="_blank" class="print-link">View Pass</a>
    </td>
</tr>

<%
    }

    if (count == 0) {
%>
<tr>
    <td colspan="12" class="error-message">No records found for today.</td>
</tr>
<%
    }

} catch (Exception e) {
    out.println("<tr><td colspan='12' class='error-message'>Error: " + e.getMessage() + "</td></tr>");
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch(Exception ex){}
    if (st != null) try { st.close(); } catch(Exception ex){}
    if (conn != null) try { conn.close(); } catch(Exception ex){}
}
%>

</tbody>
</table>
</div>

</body>
</html>
