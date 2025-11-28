<%@ page language="java" import="java.sql.*"%>
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
        "GatePass No.", "Photo", "Name", "Father Name", "Visiting Department",
        "Age", "Local Address", "Permanent Address", "Nationality",
        "Validity Period", "Issue Date", "Action"
    };
%>

<!DOCTYPE html>
<html>
<head>
<title>Foreigner Gatepass Register</title>
<meta charset="UTF-8">

<style>
/* Same styling as Contract Labour register */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f4f7f6;
    padding: 20px;
    color: #333;
}

h2 {
    color: #1e3c72;
    text-align: center;
    margin-bottom: 25px;
    text-transform: uppercase;
}

#searchInput {
    width: 97.6%;
    padding: 12px 20px;
    margin-bottom: 20px;
    border: 2px solid #ccc;
    border-radius: 8px;
    font-size: 16px;
}
#searchInput:focus { border-color: #007bff; }

img {
    display: block;
    max-width: 80px;
    height: 100px;
    object-fit: cover;
    border-radius: 4px;
}

.table-wrapper {
    box-shadow: 0 4px 8px rgba(0,0,0,.1);
    border-radius: 8px;
    overflow: hidden;
}
#registerTable {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
}
#registerTable th {
    background: #1e3c72;
    color: white;
    padding: 12px 15px;
    font-size: 15px;
}
#registerTable td {
    border: 1px solid #ddd;
    padding: 10px 15px;
}
#registerTable tr:nth-child(even) td { background: #f9f9f9; }
#registerTable tr:hover td { background: #e0f7fa; }
#registerTable td a { font-weight: 600; }

.btn-bar { text-align: center; margin-top: 25px; }
.btn {
    background: #007bff;
    color: #fff;
    border: none;
    padding: 10px 25px;
    border-radius: 6px;
    cursor: pointer;
    transition: .3s;
    margin: 0 10px;
}
.btn:hover { background: #0056b3; transform: scale(1.02); }

.error-message { color: red; font-weight: bold; text-align: center; padding: 20px; }
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

    <h2>FOREIGNER GATEPASS REGISTER</h2>

    <input type="text" id="searchInput" placeholder="Search by Name, Nationality, or any field..." onkeyup="filterTable()">

    <form action="ssaveForeignerGatePasDetails" method="post" enctype="multipart/form-data">

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

                    // Proper Oracle date format
                    SimpleDateFormat oracleFormat = new SimpleDateFormat("dd-MMM-yyyy");
                    Date today = oracleFormat.parse(oracleFormat.format(new Date()));

                    try {
                        Database db = new Database();
                        conn = db.getConnection();
                        st = conn.createStatement();

                        // FIXED alias names
                        String sql =
                        "SELECT SER_NO, NAME, FATHER_NAME, VISIT_DEPT, AGE, LOCAL_ADDRESS, " +
                        "PERMANENT_ADDRESS, NATIONALITY, " +
                        "TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE, " +
                        "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VALIDITY_FROM_STR, " +
                        "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VALIDITY_TO_STR, DEPOSITED " +
                        "FROM GATEPASS_FOREIGNER ORDER BY SER_NO DESC";

                        rs = st.executeQuery(sql);

                        while (rs.next()) {
                            count++;

                            String vf = rs.getString("VALIDITY_FROM_STR");
                            String vt = rs.getString("VALIDITY_TO_STR");
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

                <tr>
                    <td>
                        NFL/CISF/FOREIGNER/0<%= rs.getInt("SER_NO") %><br>
                        <span <%= color %>> (<%= status %>) </span>
                    </td>

                    <td>
                        <a href="ShowImageForeigner.jsp?srNo=<%=rs.getInt("SER_NO")%>" target="_blank">
                            <img src="ShowImageForeigner.jsp?srNo=<%=rs.getInt("SER_NO")%>" alt="Photo">
                        </a>
                    </td>

                    <td><%= rs.getString("NAME") %></td>
                    <td><%= rs.getString("FATHER_NAME") %></td>
                    <td><%= rs.getString("VISIT_DEPT") %></td>
                    <td><%= rs.getString("AGE") %></td>
                    <td><%= rs.getString("LOCAL_ADDRESS") %></td>
                    <td><%= rs.getString("PERMANENT_ADDRESS") %></td>
                    <td><%= rs.getString("NATIONALITY") %></td>

                    <td><%= vf %> to <%= vt %></td>
                    <td><%= rs.getString("ISSUE_DATE") %></td>

                    <td>
                        <a href="PrintForeignerGatePass.jsp?srNo=<%=rs.getInt("SER_NO")%>" class="print-link">View Foreigner Pass</a>
                    </td>
                </tr>

                <%
                        }

                        if (count == 0) {
                %>
                <tr>
                    <td colspan="<%= HEADERS.length %>" class="error-message">
                        No foreigner gatepass records found.
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
            <button type="button" class="btn" onclick="window.location.href='ForeignerGatepass.jsp'">New Entry</button>
            <button type="button" class="btn" onclick="window.print();">Print Register</button>
        </div>

    </form>

</div>

</body>
</html>
