<%@ page language="java" import="java.util.*,java.sql.*,gatepass.Database" pageEncoding="ISO-8859-1"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Contract Labour Gate Pass</title>

    <style type="text/css">
        body {
            background-color: #FFFFFF;
            color: #000000;
            font-family: Arial, sans-serif;
            margin: 10px;
        }

        table {
            border-collapse: collapse;
            width: 320px;
            height: 430px;
            margin: 0 auto;
            border: 1px solid #000;
        }

        td {
            padding: 2px;
            font-size: 11px;
            vertical-align: top;
        }

        .center {
            text-align: center;
        }

        .bold {
            font-weight: bold;
        }

        /* Print button styling */
        .print-container {
            text-align: center;
            margin-bottom: 10px;
        }

        .print-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px; /* space between icon and text */
    background-color: #007bff;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
}

.print-button img {
    vertical-align: middle;
    width: 20px;
    height: 20px;
}
.print-button:hover {
    background-color: #0056b3;
}
        /* Hide print button during printing */
        @media print {
            .print-container {
                display: none;
            }
            body {
                margin: 0;
            }
        }

        /* Printer margin reset */
        @page {
            size: auto;
            margin: 0mm;
        }
        footer {
  text-align: center;
  font-size: 12px;
  color: #777;
  margin-top: 15px;
}
    </style>
</head>

<body>
<%

/* String srNo = request.getParameter("ID"); */
    String srNo = request.getParameter("srNo");
    if (srNo == null || srNo.trim().isEmpty()) {
%>
        <p style="color:red;text-align:center;">Error: Missing or invalid Gate Pass Serial Number.</p>
<%
    } else {
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            Database db = new Database();
            conn = db.getConnection();
            st = conn.createStatement();

            String qry = "SELECT SER_NO,REF_NO,RENEWAL_NO,NAME,FATHER_NAME,DESIGNATION,AGE,"
                       + "LOCAL_ADDRESS,PERMANENT_ADDRESS,CONTRACTOR_NAME_ADDRESS,WORKSITE,"
                       + "VEHICLE_NO,IDENTIFICATION,TO_CHAR(VALIDITY_PERIOD_FROM,'DD-MON-YYYY'),"
                       + "TO_CHAR(VALIDITY_PERIOD_TO,'DD-MON-YYYY'),PHOTO_IMAGE,"
                       + "TO_CHAR(SYSDATE,'MM-MON-YYYY') "
                       + "FROM GATEPASS_CONTRACT_LABOUR WHERE SER_NO='" + srNo + "'";

            rs = st.executeQuery(qry);

            if (rs.next()) {
%>

    <!-- Print Button -->
    <div class="print-container">
        <button class="print-button" onclick="window.print();"> <img src="print.png" alt="Print" width="20" height="20"> Print Gate Pass</button>
    </div>

    <table border="1" cellpadding="0" cellspacing="0">
        <tr>
            <td colspan="10" class="center bold">CONTRACT LABOUR GATE PASS</td>
        </tr>
        <tr>
            <td colspan="7">Gate Pass Serial No:</td>
            <td colspan="3"><%= rs.getString("SER_NO") %></td>
        </tr>
        <tr>
            <td colspan="4">Contractor Name:</td>
            <td colspan="6"><%= rs.getString("CONTRACTOR_NAME_ADDRESS") %></td>
        </tr>
        <tr>
            <td colspan="10" class="center">(Work Site: <%= rs.getString("WORKSITE") %>)</td>
        </tr>
        <tr>
            <td colspan="2">Name:</td>
            <td colspan="8"><%= rs.getString("NAME") %></td>
        </tr>
        <tr>
            <td colspan="3">Father's Name:</td>
            <td colspan="3"><%= rs.getString("FATHER_NAME") %></td>
            <td colspan="4" rowspan="5" class="center">
                <img src="ShowImage.jsp?srNo=<%= rs.getString("SER_NO") %>" 
                     alt="Photo" style="width:96px;height:78px;border:1px solid #000;">
            </td>
        </tr>
        <tr>
            <td colspan="3">Designation:</td>
            <td colspan="3"><%= rs.getString("DESIGNATION") %></td>
        </tr>
        <tr>
            <td colspan="3">Age:</td>
            <td colspan="3"><%= rs.getString("AGE") %></td>
        </tr>
        <tr>
            <td colspan="3">Identification:</td>
            <td colspan="3"><%= rs.getString("IDENTIFICATION") %></td>
        </tr>
        <tr>
            <td colspan="3">Local Address:</td>
            <td colspan="3"><%= rs.getString("LOCAL_ADDRESS") %></td>
        </tr>
        <tr>
            <td colspan="3">Permanent Address:</td>
            <td colspan="7"><%= rs.getString("PERMANENT_ADDRESS") %></td>
        </tr>
        <tr>
            <td colspan="3">Vehicle No:</td>
            <td colspan="7"><%= rs.getString("VEHICLE_NO") %></td>
        </tr>
        <tr>
            <td colspan="3">Valid From / To:</td>
            <td colspan="7"><%= rs.getString(14) %> - <%= rs.getString(15) %></td>
        </tr>
        <tr style="height: 60px;">
            <td colspan="5" rowspan="3" class="center">Sign of Card Holder</td>
            <td colspan="5" rowspan="3" class="center">Sign of Issuing Authority</td>
        </tr>
    </table>

<%
            } else {
%>
                <p style="color:red;text-align:center;">No record found for Serial No: <%= srNo %></p>
<%
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (st != null) try { st.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>
<footer>© 2025 Gate Pass Management System | NFL Panipat</footer>
</body>
</html>
