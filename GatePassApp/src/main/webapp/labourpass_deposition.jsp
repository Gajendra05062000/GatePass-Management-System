<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%
    // -----------------------------------
    // SECURITY HEADERS
    // -----------------------------------
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // -----------------------------------
    // LOGIN CHECK
    // -----------------------------------
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String srNo = request.getParameter("srNo");
    String action = request.getParameter("action");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Labour Pass Deposition & Details</title>

<style>
/* ------------------------------------------------------------------
   PROFESSIONAL STYLE OVERHAUL
   ------------------------------------------------------------------ */

/* === Base & Layout === */
body {
    font-family: 'Segoe UI', Arial, sans-serif;
    background-color: #f4f5f7;
    color: #333;
    margin: 0;
    padding-top: 20px;
    padding-bottom: 40px;
}

/* --- Input Form Styling --- */
.input-form {
    margin: 0 auto;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 15px;
    background: #fff;
    padding: 15px;
    border-radius: 8px;
    max-width: 600px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.input-form label {
    font-weight: 600;
    color: #1e3c72;
    white-space: nowrap;
}

.input-form input[type=text] {
    padding: 8px 12px;
    width: 200px;
    border: 1px solid #ced4da;
    border-radius: 5px;
    font-size: 14px;
}

.input-form input[type=submit] {
    background: #1e3c72;
    padding: 8px 25px;
    border-radius: 5px;
    color: white;
    border: none;
    cursor: pointer;
    font-weight: 600;
    transition: background-color 0.3s;
}

.input-form input[type=submit]:hover {
    background: #152d5b;
}

.error-message {
    text-align: center;
    color: #dc3545;
    font-size: 16px;
    font-weight: 500;
    margin-top: 20px;
}

/* === Pass Card Styling === */
.card {
    max-width: 850px;
    margin: 25px auto;
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,.1);
}

.pass-header {
    border-bottom: 2px solid #1e3c72;
    padding-bottom: 10px;
    margin-bottom: 25px;
}

.pass-header h3 {
    color: #1e3c72;
    text-align: center;
    margin: 0;
    font-size: 22px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* --- Data and Photo Layout --- */
.content-section {
    display: flex;
    gap: 30px;
    align-items: flex-start; /* Important for alignment */
}

.data-area {
    flex: 1;
}

.photo-area {
    width: 150px;
    flex-shrink: 0;
    text-align: center;
}

/* --- Data Table Styling --- */
.data-table {
    width: 100%;
    border-collapse: collapse;
}

.data-table td {
    padding: 10px 15px;
    border-bottom: 1px dashed #ddd;
    vertical-align: middle;
}

/* Field Names (Labels) */
.data-table td:first-child {
    font-weight: 600;
    color: #444;
    background: #f7f7f7;
    width: 35%; /* Adjusted width for labels */
    border-right: 1px solid #eee;
    -webkit-print-color-adjust: exact;
    color-adjust: exact;
}

/* Field Values */
.data-table .value-cell {
    font-weight: 500;
    color: #000;
}

/* Highlight Name */
.data-table .name-cell {
    font-weight: 700;
    color: #1e3c72;
}

/* Validity Styling */
.validity-from {
    color: #28a745; /* Green */
    font-weight: 700;
}
.validity-to {
    color: #dc3545; /* Red */
    font-weight: 700;
}

/* --- Photo Styling --- */
.photo {
    width: 130px;
    height: 170px;
    border: 4px solid #1e3c72;
    object-fit: cover;
    border-radius: 6px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    margin-top: 10px; /* Aligns visually with data table */
}

/* --- Action Button Styling --- */
.action-container {
    text-align: center;
    margin-top: 30px;
    padding-top: 25px;
    border-top: 1px solid #eee;
}

.action-btn {
    padding: 12px 30px;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-weight: 600;
    font-size: 15px;
    transition: background-color 0.3s;
}

.active-btn {
    background: #28a745; /* Green */
}
.active-btn:hover {
    background: #1e7e34;
}
.disabled-btn {
    background: #6c757d; /* Grey */
    cursor: default;
}
.expired-btn {
    background: #dc3545; /* Red */
    cursor: default;
}

/* --- Print Optimization --- */
@media print {
    .input-form, .action-container { display: none; }
    body { background-color: white; padding: 0; }
    .card {
        box-shadow: none;
        border: none;
        margin: 0;
        padding: 0;
        max-width: none;
    }
    /* Ensure shaded backgrounds print */
    .data-table td:first-child {
        background-color: #f7f7f7 !important;
        -webkit-print-color-adjust: exact;
        color-adjust: exact;
    }
    .pass-header h3 {
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
function depositPass(srNo){
    if(confirm("Are you sure to mark this pass as DEPOSITED? This will also decrement the active contract count.")){
        window.location.href="labourpass_deposition.jsp?action=deposit&srNo="+srNo;
    }
}
</script>

</head>
<body>

<form method="get" class="input-form">
    <label>Labour/Trainee Pass No:</label>
    <input type="text" name="srNo" value="<%= (srNo==null?"":srNo) %>" placeholder="Enter Gate Pass No">
    <input type="submit" value="View">
</form>

<%
    if (srNo == null || srNo.trim().equals("")) {
%>
        <p class="error-message">Please enter a pass number.</p>
<%
        return;
    }

    // ------------------------------------
    // ACTION: MARK AS DEPOSITED
    // ------------------------------------
    if ("deposit".equals(action)) {

        Connection c1 = null, c2 = null;
        PreparedStatement ps1 = null, ps2 = null;
        ResultSet rsC = null;

        try {
            Database db = new Database();
            c1 = db.getConnection();

            // 1. FIND CONTRACT ID FIRST
            String findContract = "SELECT CONTRACT_NAME_ID FROM GATEPASS_CONTRACT_LABOUR WHERE SER_NO = ?";
            ps1 = c1.prepareStatement(findContract);
            ps1.setString(1, srNo);
            rsC = ps1.executeQuery();
            String contractDisplayId = null;
            if (rsC.next()) {
            	contractDisplayId = rsC.getString("CONTRACT_NAME_ID");
            }
            // Extract the numerical Contract ID from the start of the string (e.g., "(123) ABC Contract")
            String contractId = null;
            if (contractDisplayId != null && contractDisplayId.startsWith("(")) {
                int endIndex = contractDisplayId.indexOf(")");
                if (endIndex > 0) {
                    contractId = contractDisplayId.substring(1, endIndex).trim();
                }
            }

            // 2. UPDATE LABOUR TABLE
            String upd = "UPDATE GATEPASS_CONTRACT_LABOUR SET DEPOSITED='Y' WHERE SER_NO=?";
            ps1 = c1.prepareStatement(upd);
            ps1.setString(1, srNo);
            ps1.executeUpdate();

            // 3. DECREASE CONTRACT COUNT BY 1 (if contractId was successfully extracted)
            if (contractId != null && !contractId.isEmpty()) {
                c2 = db.getConnection();
                // Ensure the ID is numeric before binding it as a string for the UPDATE
                // Note: The original logic used two connections. Keeping the structure but ensuring safe execution.
                String updCount = "UPDATE GATEPASS_CONTRACT SET COUNT = COUNT - 1 WHERE ID=?";
                ps2 = c2.prepareStatement(updCount);
                ps2.setString(1, contractId);
                ps2.executeUpdate();
            }

%>
            <script>
            alert("Gatepass Deposited Successfully! Contract count updated.");
            window.location.href="labourpass_deposition.jsp?srNo=<%=srNo%>";
            </script>
<%
        } catch(Exception ex){
%>
            <script>alert("Error during deposition: <%= ex.getMessage().replace("'", "\\'") %>");</script>
<%
        } finally {
            if (rsC != null) try { rsC.close(); } catch(Exception e){}
            if (ps1 != null) try { ps1.close(); } catch(Exception e){}
            if (ps2 != null) try { ps2.close(); } catch(Exception e){}
            if (c1 != null) try { c1.close(); } catch(Exception e){}
            if (c2 != null) try { c2.close(); } catch(Exception e){}
        }

        return;
    }

    // ------------------------------------
    // DISPLAY PASS DETAILS
    // ------------------------------------
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        Database db = new Database();
        conn = db.getConnection();
        st = conn.createStatement();

        // Include all necessary fields for display
        String sql =
            "SELECT SER_NO, NAME, FATHER_NAME, DESIGNATION, AGE, " +
            "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VF, " +
            "TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VT, " +
            "TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE, " +
            "AADHAR, PHONE, PHOTO, DEPOSITED, LOCAL_ADDRESS, CONTRACTOR_NAME_ADDRESS, WORKSITE " +
            "FROM GATEPASS_CONTRACT_LABOUR WHERE SER_NO='" + srNo + "'";

        rs = st.executeQuery(sql);

        if (!rs.next()) {
%>
            <p class="error-message">No Contract Labour/Trainee record found for Pass No: <%= srNo %>.</p>
<%
        } else {

            // CHECK EXPIRED
            String vToString = rs.getString("VT");
            SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
            Date validTo = sdf.parse(vToString);
            Date today = new Date();

            boolean expired = today.after(validTo);
            boolean deposited = "Y".equalsIgnoreCase(rs.getString("DEPOSITED"));
%>

<div class="card">

    <div class="metadata-top">
            <div class="metadata-top-item" style="margin-right: auto;">
                <strong>LABOUR/TRAINEE PASS NO:</strong>
                <span class="pass-number">NFL/CISF/LABOUR/0<%= rs.getString("SER_NO") %></span>
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
                <tr><td>Father Name</td><td class="value-cell"><%=rs.getString("FATHER_NAME")%></td></tr>
                <tr><td>Age</td><td class="value-cell"><%=rs.getString("AGE")%></td></tr>
                <tr><td>Designation</td><td class="value-cell"><%=rs.getString("DESIGNATION")%></td></tr>
                <tr><td>Aadhar No.</td><td class="value-cell"><%=rs.getString("AADHAR")%></td></tr>
                <tr><td>Phone</td><td class="value-cell"><%=rs.getString("PHONE")%></td></tr>
                <tr><td>Local Address</td><td class="value-cell"><%=rs.getString("LOCAL_ADDRESS")%></td></tr>
                <tr><td>Worksite</td><td class="value-cell"><%=rs.getString("WORKSITE")%></td></tr>
                <tr><td>Contractor</td><td class="value-cell"><%=rs.getString("CONTRACTOR_NAME_ADDRESS")%></td></tr>
                <tr><td>Issue Date</td><td class="value-cell"><%=rs.getString("ISSUE_DATE")%></td></tr>
                <tr>
                    <td>Validity</td>
                    <td class="value-cell">
                        <span class="validity-from">FROM: <%=rs.getString("VF")%></span>
                        &nbsp; | &nbsp;
                        <span class="validity-to">TO: <%=rs.getString("VT")%></span>
                    </td>
                </tr>
            </table>
        </div>
        
        <div class="photo-area">
            <img src="ShowImage.jsp?srNo=<%=rs.getString("SER_NO")%>" class="photo" alt="Labour Photo">
        </div>
    </div>

    <div class="action-container">

<%
        if (expired) {
%>
        <button class="action-btn expired-btn" disabled>EXPIRED - CANNOT DEPOSIT</button>

<%
        } else if (deposited) {
%>
        <button class="action-btn disabled-btn" disabled>PASS DEPOSITED SUCCESSFULLY</button>

<%
        } else {
%>
        <button class="action-btn active-btn" onclick="depositPass('<%=rs.getString("SER_NO")%>')">
            Mark as DEPOSITED
        </button>
<%
        }
%>

    </div>
</div>

<%
        } // end else rs.next()
    } catch(Exception ex){
        out.println("<p class='error-message card'>Database Error: " + ex.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (st != null) try { st.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>

</body>
</html>