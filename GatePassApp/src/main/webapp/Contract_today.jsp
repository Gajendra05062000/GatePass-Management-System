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
    // LOGIN CHECK
    // ==========================================================
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%! 
    private static final String[] HEADERS = {
        "Contract No.", "Contract Name", "Contractor",
        "Department", "Validity (From)", "Validity (To)",
        "Reg. No.", "Status", "Action"
    };
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Contract Register - Today</title>

<style>
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f4f7f6;
    padding: 20px;
}
h2 {
    text-align: center;
    color: #1e3c72;
    margin-bottom: 25px;
    text-transform: uppercase;
}

/* Search Bar */
#searchInput {
    width: 100%;
    padding: 12px 20px;
    margin-bottom: 20px;
    border: 2px solid #ccc;
    border-radius: 8px;
    font-size: 16px;
}
#searchInput:focus { border-color: #007bff; }

/* Table */
#contractTable {
    border-collapse: collapse;
    width: 100%;
    background: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 3px 8px rgba(0,0,0,.1);
}
#contractTable th {
    background: #1e3c72;
    color: white;
    padding: 12px 15px;
}
#contractTable td {
    border: 1px solid #ddd;
    padding: 10px 15px;
}
#contractTable tr:nth-child(even) td { background: #f9f9f9; }
#contractTable tr:hover td { background: #e0f7fa; }

.print-link {
    text-decoration: none;
    color: #fff;
    background: #007bff;
    padding: 6px 10px;
    border-radius: 4px;
    font-size: 13px;
}
.print-link:hover { background: #0056b3; }

.error-message { color: red; text-align: center; font-weight: bold; padding: 20px; }
</style>

<script>
// Search Filter
function filterTable() {
    const filter = document.getElementById("searchInput").value.toUpperCase();
    const rows = document.querySelectorAll("#contractTable tbody tr");

    rows.forEach(row => {
        row.style.display = row.innerText.toUpperCase().includes(filter) ? "" : "none";
    });
}
</script>
</head>

<body>

<h2>CONTRACT REGISTER — TODAY</h2>

<input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search records...">

<div class="table-wrapper">
<table id="contractTable">
<thead>
<tr>
<%
    for (String h : HEADERS) {
%>
    <th><%=h%></th>
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

int count = 0;

SimpleDateFormat df = new SimpleDateFormat("dd-MMM-yyyy");
Date today = df.parse(df.format(new Date()));

try {
    Database db = new Database();
    conn = db.getConnection();
    st = conn.createStatement();

    // ================================
    // TODAY ONLY CONTRACTS
    // ================================
    String sql =
        "SELECT ID, CONTRACT_NAME, CONTRACTOR_NAME, DEPARTMENT, " +
        "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VF_STR, " +
        "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VT_STR, " +
        "VALIDITY_FROM AS VF_DATE, VALIDITY_TO AS VT_DATE, " +
        "REGISTRATION, DEPOSITED, " +
        "TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE " +
        "FROM GATEPASS_CONTRACT " +
        "WHERE TRUNC(UPDATE_DATE)=TRUNC(SYSDATE) " +
        "ORDER BY ID DESC";

    rs = st.executeQuery(sql);

    while (rs.next()) {
        count++;

        // Parse validity dates
        Date vf = rs.getDate("VF_DATE");
        Date vt = rs.getDate("VT_DATE");
        String deposited = rs.getString("DEPOSITED");

        String status = "Expired";
        String color = "style='color:red;font-weight:bold;'";

        if (vf != null && vt != null) {
            boolean active = (!today.before(vf) && !today.after(vt));

            if (active) {
                if ("Y".equalsIgnoreCase(deposited)) {
                    status = "Depositted";
                    color = "style='color:orange;font-weight:bold;'";
                } else {
                    status = "Active";
                    color = "style='color:green;font-weight:bold;'";
                }
            }
        }
%>

<tr>
    <td>NFL/CISF/CONTRACT/0<%=rs.getInt("ID")%></td>
    <td><%=rs.getString("CONTRACT_NAME")%></td>
    <td><%=rs.getString("CONTRACTOR_NAME")%></td>
    <td><%=rs.getString("DEPARTMENT")%></td>
    <td><%=rs.getString("VF_STR")%></td>
    <td><%=rs.getString("VT_STR")%></td>
    <td><%=rs.getString("REGISTRATION")%></td>

    <td><span <%=color%>> <%=status%> </span></td>

    <td>
        <a href="PrintContract.jsp?id=<%=rs.getInt("ID")%>" target="_blank" class="print-link">
            View Contract
        </a>
    </td>
</tr>

<%
    } // end while

    if (count == 0) {
%>
<tr><td colspan="9" class="error-message">No contract records found for today.</td></tr>
<%
    }

} catch (Exception e) {
    out.println("<tr><td colspan='9' class='error-message'>Error: " + e.getMessage() + "</td></tr>");
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
