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
        "GatePass No.", "Photo", "Name", "Father Name", "Visiting Department",
        "Age", "Local Address", "Permanent Address", "Nationality",
        "Validity Period", "Issue Date", "Status", "Action"
    };
%>

<!DOCTYPE html>
<html>
<head>
<title>Foreigner Gatepass - Today</title>
<meta charset="UTF-8">

<style>
/* Same styling used in other registers */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f4f7f6;
    padding: 20px;
}
h2 {
    text-align: center;
    color: #1e3c72;
    margin-bottom: 20px;
    text-transform: uppercase;
}
#searchInput {
    width: 97%;
    padding: 12px;
    border: 2px solid #ccc;
    border-radius: 8px;
    margin-bottom: 20px;
}
#searchInput:focus { border-color: #007bff; }
.table-wrapper { box-shadow: 0 4px 8px rgba(0,0,0,.1); border-radius: 8px; overflow: hidden; }
#registerTable { width: 100%; border-collapse: collapse; background: #fff; }
#registerTable th {
    background: #1e3c72;
    color: white;
    padding: 12px;
    text-transform: uppercase;
    font-size: 13px;
}
#registerTable td {
    border: 1px solid #ddd;
    padding: 10px;
}
#registerTable tr:nth-child(even) td { background: #f9f9f9; }
#registerTable tr:hover td { background: #e0f7fa; }

img {
    max-width: 80px;
    height: 100px;
    object-fit: cover;
    border-radius: 4px;
}

.print-link {
    color: #fff;
    background: #007bff;
    padding: 6px 10px;
    border-radius: 4px;
    text-decoration: none;
}
.print-link:hover { background: #0056b3; }

.error-message { text-align: center; color: red; padding: 20px; font-weight: bold; }
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

<h2>Foreigner Gatepass Issued Today</h2>
<input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search records...">

<div class="table-wrapper">
<table id="registerTable">
<thead>
<tr>
<%
    for (String h : HEADERS) {
%>
    <th><%= h %></th>
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

// Date formatting for Status comparison
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
        "SELECT SER_NO, NAME, FATHER_NAME, VISIT_DEPT, AGE, LOCAL_ADDRESS, " +
        "PERMANENT_ADDRESS, NATIONALITY, " +
        "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VF_STR, " +
        "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VT_STR, " +
        "VALIDITY_FROM AS VF_DATE, VALIDITY_TO AS VT_DATE, " +
        "TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE, " +
        "DEPOSITED " +
        "FROM GATEPASS_FOREIGNER " +
        "WHERE TRUNC(UPDATE_DATE)=TRUNC(SYSDATE) " +
        "ORDER BY SER_NO DESC";

    rs = st.executeQuery(sql);

    while (rs.next()) {
        count++;

        Date fromDate = rs.getDate("VF_DATE");
        Date toDate   = rs.getDate("VT_DATE");
        String deposited = rs.getString("DEPOSITED");

        String status = "Invalid";
        String color = "style='color:gray;font-weight:bold;'";

        if (fromDate != null && toDate != null) {

            boolean isActive = (!today.before(fromDate) && !today.after(toDate));

            if (isActive) {
                if ("Y".equalsIgnoreCase(deposited)) {
                    status = "Gatepass Taken";
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
    <td>NFL/CISF/FOREIGNER/0<%=rs.getInt("SER_NO")%><br>
        <span <%=color%>> (<%=status%>) </span>
    </td>

    <td>
        <a href="ShowImageForeigner.jsp?srNo=<%=rs.getInt("SER_NO")%>" target="_blank">
            <img src="ShowImageForeigner.jsp?srNo=<%=rs.getInt("SER_NO")%>" alt="Photo">
        </a>
    </td>

    <td><%=rs.getString("NAME")%></td>
    <td><%=rs.getString("FATHER_NAME")%></td>
    <td><%=rs.getString("VISIT_DEPT")%></td>
    <td><%=rs.getString("AGE")%></td>
    <td><%=rs.getString("LOCAL_ADDRESS")%></td>
    <td><%=rs.getString("PERMANENT_ADDRESS")%></td>
    <td><%=rs.getString("NATIONALITY")%></td>

    <td><%=rs.getString("VF_STR")%> to <%=rs.getString("VT_STR")%></td>

    <td><%=rs.getString("ISSUE_DATE")%></td>

    <td>
        <a href="PrintForeignerGatePass.jsp?srNo=<%=rs.getInt("SER_NO")%>" class="print-link" target="_blank">
            View Pass
        </a>
    </td>
</tr>

<%
    } // end while

    if (count == 0) {
%>
<tr>
    <td colspan="13" class="error-message">No foreigner passes issued today.</td>
</tr>
<%
    }

} catch (Exception ex) {
    out.println("<tr><td colspan='13' class='error-message'>Error: " + ex.getMessage() + "</td></tr>");
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

</body>
</html>
