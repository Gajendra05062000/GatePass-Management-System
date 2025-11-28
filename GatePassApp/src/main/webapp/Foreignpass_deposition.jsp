<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>

<%
//==========================================================
//🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
//==========================================================
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
response.setDateHeader("Expires", 0); // Proxies.

//==========================================================
//🔑 SESSION AUTHENTICATION CHECK
//==========================================================
if (session.getAttribute("username") == null) {
	response.sendRedirect("login.jsp");
	return;
}

    String srNo = request.getParameter("srNo");
    String action = request.getParameter("action");   // deposit or view
%>

<!DOCTYPE html>
<html>
<head>
<title>Foreigner Pass Deposition & Details</title>
<meta charset="UTF-8">

<style type="text/css">
        /* Base Reset and Typography */
        body {
            margin: 0;
            font-family: 'Segoe UI', Arial, sans-serif;
            background-color: #f4f5f7; /* Light background */
            color: #333;
            padding-top: 20px;
        }

        /* --- Input Form Styling --- */
        .input-form {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 30px;
            padding: 15px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            max-width: 600px;
            margin: 20px auto 30px auto;
        }
        .input-form label {
            margin-top: 8px;
            font-weight: 600;
            color: #1e3c72;
            white-space: nowrap;
        }
        .input-form input[type="text"] {
            padding: 8px 12px;
            border: 1px solid #ced4da;
            border-radius: 5px;
            width: 200px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .input-form input[type="text"]:focus {
            border-color: #007bff;
            outline: none;
        }
        .input-form input[type="submit"] {
            padding: 8px 25px;
            background: #1e3c72;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        .input-form input[type="submit"]:hover {
            background: #152d5b;
        }
        .error-message {
            color: #dc3545;
            text-align: center;
            font-weight: 500;
            margin-bottom: 20px;
        }


        /* === PASS CARD STYLING === */
        .card {
            width: 100%;
            max-width: 850px; 
            padding: 30px;
            margin: 20px auto;
            border: 1px solid #e0e6ed;
            font-size: 14px;
            background-color: #fff;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1); 
            border-radius: 12px;
        }
        .pass-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #1e3c72;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .pass-header h3 {
            margin: 0;
            font-size: 20px;
            color: #1e3c72;
            font-weight: 700;
        }
        .pass-header .issue-date {
            font-weight: 600;
            color: #6c757d;
            font-size: 14px;
        }

        /* --- Photo & Main Data Section --- */
        .content-section {
            display: flex;
            gap: 30px;
            margin-top: 20px;
        }
        .data-area {
            flex: 1;
        }
        .photo-area {
            width: 150px; 
            flex-shrink: 0;
            text-align: center;
            padding-top: 10px; /* Offset for table padding */
        }
        .photo {
            width: 130px; 
            height: 170px;
            border: 4px solid #1e3c72; 
            object-fit: cover;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            border-radius: 6px;
        }

        /* --- Data Table Styling --- */
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 0; 
        }

        .data-table td {
            padding: 10px 15px;
            vertical-align: middle;
            border-bottom: 1px dashed #ddd; /* Light separator */
        }
        
        /* Field Names (Labels) */
        .data-table td:first-child {
            font-weight: 600;
            color: #444;
            width: 35%; /* Adjusted width for labels */
            background-color: #f7f7f7; 
            -webkit-print-color-adjust: exact;
            color-adjust: exact;
            border-right: 1px solid #eee;
        }
        /* Field Values */
        .data-table td:nth-child(2) {
            color: #000;
            font-weight: 500;
        }
        
        /* Highlight key values */
        .data-table .name-cell {
            font-weight: 700;
            color: #1e3c72;
        }

        /* Group Header for Contract Info */
        .group-separator {
            font-size: 16px;
            font-weight: 700;
            color: #1e3c72;
            background-color: #e3f2fd;
            padding: 10px 15px;
            border-bottom: 2px solid #1e3c72;
            margin-top: 25px;
            margin-bottom: 0;
            border-radius: 4px 4px 0 0;
            -webkit-print-color-adjust: exact;
            color-adjust: exact;
        }
        .contract-table {
             border-radius: 0 0 4px 4px;
             border: 1px solid #eee;
             border-top: none;
        }
        .contract-table td:first-child {
            width: 25%;
        }

        /* Validity Text Styling */
        .validity-from {
            color: #28a745; /* Green */
            font-weight: 700;
        }
        .validity-to {
            color: #dc3545; /* Red */
            font-weight: 700;
        }

        /* --- Deposit Button --- */
        .action-container {
            text-align: center;
            padding: 25px 0 0 0;
            border-top: 1px solid #eee;
            margin-top: 30px;
        }
        .deposit-btn {
            padding: 12px 30px;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            transition: background-color 0.3s;
        }
        .deposit-btn.active {
            background-color: #28a745; /* Green */
        }
        .deposit-btn.active:hover {
            background-color: #1e7e34;
        }
        .deposit-btn.disabled {
            background-color: #ffc107; /* Orange/Warning */
            cursor: default;
            color: #333;
        }

        /* --- Print Optimization --- */
        @media print {
            .input-form, .action-container { display: none; }
            body {
                background-color: white;
                padding: 0;
            }
            .card {
                box-shadow: none;
                border: none;
                margin: 0;
                padding: 0;
                max-width: none;
            }
            /* Ensure shaded backgrounds print */
            .data-table td:first-child, .group-separator {
                background-color: #f7f7f7 !important; 
                -webkit-print-color-adjust: exact;
                color-adjust: exact;
            }
            .photo {
                border-color: #1e3c72 !important;
            }
            .pass-header h3, .group-separator {
                color: #1e3c72 !important;
            }
            .pass-header {
                border-bottom-color: #1e3c72 !important;
            }
        }
                .metadata-top {
            width: 100%; 
            display: flex;
            justify-content: space-between;
            
            /* 💡 ADDED DOTTED LINE HERE (ABOVE) */
            border-top: 1px dotted #888; 
            
            /* Adjusted padding to fit line above */
            padding: 15px 0 10px 0; 
            margin-top: 15px;
            order: 3; 
        }
        .metadata-top-item {
            font-size: 15px;
            font-weight: 600;
            color: #555;
            background-color: #f7f7f7;
            padding: 8px 12px;
            border-radius: 4px;
            border: 1px solid #eee;
        }
        .metadata-top-item strong {
            color: #1e3c72;
            margin-right: 5px;
        }
        .metadata-top-item .pass-number {
            font-size: 17px; 
            font-weight: 800;
            color: #cc0000;
        }
</style>
<script>
function depositPass(srNo) {
    if (!confirm("Confirm marking this pass as DEPOSITED?")) return;
    // Redirect to trigger the 'deposit' action logic in the JSP
    window.location.href = "Foreignpass_deposition.jsp?action=deposit&srNo=" + srNo;
}
</script>

</head>
<body>

<form method="get" class="input-form">
    <label for="srNoInput">Foreigner Pass No:</label>
    <input type="text" id="srNoInput" name="srNo" value="<%= (srNo==null?"":srNo) %>"
           placeholder="Enter Pass Number">
    <input type="submit" value="View">
</form>

<%
    // NO SERIAL PROVIDED
    if (srNo == null || srNo.trim().equals("")) {
%>
        <p class="error-message">Please enter a valid Pass Number to view details.</p>
<%
        return;
    }

    /* ==========================================================
       ACTION 1: UPDATE DEPOSITED STATUS
    ========================================================== */
    if ("deposit".equals(action)) {

        Connection connD = null;
        PreparedStatement psD = null;

        try {
            Database db = new Database();
            connD = db.getConnection();

            // Using parameterized query for security
            String upd = "UPDATE GATEPASS_FOREIGNER SET DEPOSITED='Y' WHERE SER_NO=?";
            psD = connD.prepareStatement(upd);
            psD.setString(1, srNo);
			
            int done = psD.executeUpdate();

            if (done > 0) {
%>
                <script>
                    alert("Gatepass marked as DEPOSITED successfully!");
                    window.location.href="Foreignpass_deposition.jsp?srNo=<%=srNo%>";
                </script>
<%
            } else {
%>
                <script>alert("Record not found (SR No: <%=srNo%>). Update failed.");</script>
<%
            }
        } catch(Exception ex) {
%>
            <script>alert("Database Error: <%=ex.getMessage().replace("'", "\\'")%>");</script>
<%
        } finally {
            if (psD != null) try { psD.close(); } catch(Exception ignore){}
            if (connD != null) try { connD.close(); } catch(Exception ignore){}
        }
        return; // Stop execution after deposit action
    }

    /* ==========================================================
       ACTION 2: SHOW PASS DETAILS
    ========================================================== */

    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        Database db = new Database();
        conn = db.getConnection();
        st = conn.createStatement();

        // Optimized SQL query (ensure all columns are correctly named in DB)
        String sql =
            "SELECT SER_NO, NAME, FATHER_NAME, AGE, " +
            "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VF, " +
            "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VT, " +
            "TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE, " +
            "IDCARD, PHONE, PHOTO, DEPOSITED " +
            "FROM GATEPASS_FOREIGNER WHERE SER_NO='" + srNo + "'";

        rs = st.executeQuery(sql);

        if (!rs.next()) {
%>
            <p class="error-message">No Foreigner Pass record found for Pass No: <%=srNo%></p>
<%
        } else {
%>

<div class="card">
     <div class="metadata-top">
            <div class="metadata-top-item" style="margin-right: auto;">
                <strong>FOREIGNER PASS NO:</strong>
                <span class="pass-number">NFL/CISF/FOREIGNER/0<%= rs.getString("SER_NO") %></span>
            </div>
            <div class="metadata-top-item" style="margin-left: auto;">
                <strong>Issued On:</strong>
                <%= rs.getString("ISSUE_DATE") %>
            </div>
        </div>
    <div class="content-section">
        
        <div class="data-area">
            <table class="data-table">
                <tr><td>Name</td><td class="name-cell"><%=rs.getString("NAME")%></td></tr>
                <tr><td>Father Name</td><td><%=rs.getString("FATHER_NAME")%></td></tr>
                <tr><td>Age</td><td><%=rs.getString("AGE")%></td></tr>
                <tr><td>ID Cardd No</td><td><%=rs.getString("IDCARD")%></td></tr>
                <tr><td>Contact No</td><td><%=rs.getString("PHONE")%></td></tr>
                <tr>
            <td>Validity Period</td>
            <td>
                <span class="validity-from">FROM: <%=rs.getString("VF")%></span>
                &nbsp; | &nbsp;
                <span class="validity-to">TO: <%=rs.getString("VT")%></span>
            </td>
        </tr>
            </table>
        </div>

        <div class="photo-area">
            <img class="photo" src="ShowImageForeigner.jsp?srNo=<%=rs.getString("SER_NO")%>" alt="Foreigner Photo">
        </div>
    </div>
    
   
    <div class="action-container">
<%
        if ("Y".equalsIgnoreCase(rs.getString("DEPOSITED"))) {
%>
            <button class="deposit-btn disabled">
                DEPOSITED SUCCESSFULLY 
            </button>
<%
        } else {
%>
            <button onclick="depositPass('<%=rs.getString("SER_NO")%>')" 
                    class="deposit-btn active">
                Mark as DEPOSITED
            </button>
<%
        }
%>
    </div>

</div>

<%
        } // end else record found
    } catch(Exception e) {
        // Output error in a styled box
        out.println("<div class='card'><p class='error-message' style='margin-bottom:0;'>Database Error: "+e.getMessage()+"</p></div>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception ignore){}
        if (st != null) try { st.close(); } catch(Exception ignore){}
        if (conn != null) try { conn.close(); } catch(Exception ignore){}
    }
%>

</body>
</html>