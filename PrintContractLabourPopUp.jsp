<%@ page language="java" import="java.util.*, java.sql.*, gatepass.Database" pageEncoding="UTF-8"%>
<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Foreigner Gate Pass</title>

    <style type="text/css">
        body {
            background-color: #FFFFFF;
            color: #000000;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }

        table {
            border-collapse: collapse;
            width: 320px;
            height: 450px;
            margin: 20px auto;
            border: 1px solid #000;
        }

        td {
            font-size: 12px;
            padding: 3px;
            vertical-align: top;
        }

        .center {
            text-align: center;
        }

        .bold {
            font-weight: bold;
        }

        .instructions {
            font-size: 11px;
        }

        /* Print button styling */
        .print-container {
            text-align: center;
            margin-bottom: 15px;
        }

        .print-button {
            background-color: #007BFF;
            color: white;
            border: none;
            padding: 8px 14px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
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
                padding: 0;
            }
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
    String srNo = request.getParameter("srNo");
    if (srNo == null || srNo.trim().isEmpty()) {
%>
        <p style="color:red; text-align:center;">Error: Missing or invalid Gate Pass Serial Number (srNo).</p>
<%
    } else {
        Connection conn = null;
        Statement st = null;
        ResultSet rs = null;
        try {
            Database db = new Database();
            conn = db.getConnection();
            st = conn.createStatement();

            String qry = "SELECT SER_NO,VISIT_DEPT,WORKSITE,NAME,FATHER_NAME,DESIGNATION,AGE,LOCAL_ADDRESS,"
                       + "PERMANENT_ADDRESS,NATIONALITY,TO_CHAR(VALIDITY_PERIOD_FROM,'DD-MON-YYYY'),"
                       + "TO_CHAR(VALIDITY_PERIOD_TO,'DD-MON-YYYY'),PHOTO_IMAGE,"
                       + "TO_CHAR(SYSDATE,'DD-MON-YYYY') FROM GATEPASS_FOREIGNER WHERE SER_NO='" + srNo + "'";

            rs = st.executeQuery(qry);

            if (rs.next()) {
%>

    <!-- Print Button -->
    <div class="print-container">
        <button class="print-button" onclick="window.print();">🖨️ Print Gate Pass</button>
    </div>

    <table cellpadding="0" cellspacing="0">
        <tr>
            <td colspan="10" class="center bold">FOREIGNER GATE PASS</td>
        </tr>
        <tr>
            <td colspan="7">Foreigner Gate Pass Ser No.:</td>
            <td colspan="3"><b><%= rs.getString(1) %></b></td>
        </tr>
        <tr>
            <td colspan="4">Visiting Dept:</td>
            <td colspan="6"><%= rs.getString(2) %></td>
        </tr>
        <tr>
            <td colspan="10" class="center">(Work Site: NFL, Panipat)</td>
        </tr>
        <tr>
            <td colspan="2">Name:</td>
            <td colspan="8"><%= rs.getString(4) %></td>
        </tr>
        <tr>
            <td colspan="3">Father's Name:</td>
            <td colspan="3"><%= rs.getString(5) %></td>
            <td colspan="4" rowspan="5" class="center">
                <img src="ShowImage.jsp?srNo=<%= rs.getString(1) %>" 
                     alt="Photo" style="width:100px;height:85px;border:1px solid #000;">
            </td>
        </tr>
        <tr>
            <td colspan="3">Designation:</td>
            <td colspan="3"><%= rs.getString(6) %></td>
        </tr>
        <tr>
            <td colspan="2">Age:</td>
            <td colspan="4"><%= rs.getString(7) %></td>
        </tr>
        <tr>
            <td colspan="3">Local Address:</td>
            <td colspan="7"><%= rs.getString(8) %></td>
        </tr>
        <tr>
            <td colspan="3">Permanent Address:</td>
            <td colspan="7"><%= rs.getString(9) %></td>
        </tr>
        <tr>
            <td colspan="3">Nationality:</td>
            <td colspan="7"><%= rs.getString(10) %></td>
        </tr>
        <tr>
            <td colspan="3">Date of Issue:</td>
            <td colspan="7"><%= rs.getString(14) %></td>
        </tr>
        <tr>
            <td colspan="3">Valid From / To:</td>
            <td colspan="7"><%= rs.getString(11) %> - <%= rs.getString(12) %></td>
        </tr>
        <tr>
            <td colspan="5" class="center">Sign of Card Holder</td>
            <td colspan="5" class="center">Sign of Issuing Authority with Stamp</td>
        </tr>
        <tr>
            <td colspan="10" class="center bold">INSTRUCTIONS</td>
        </tr>
        <tr>
            <td colspan="10" class="instructions">
                1. This card must be produced before security staff when demanded.<br>
                2. This card is not transferable.<br>
                3. Loss of card must be reported immediately to the issuing authority.<br>
                4. The card holder is not guaranteed employment by the contractor. This only permits entry to factory premises as required.
            </td>
        </tr>
    </table>

<%
            } else {
%>
                <p style="color:red; text-align:center;">No record found for Serial No: <%= srNo %></p>
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

<script>
    // Optional: Auto-open print dialog after loading (uncomment if needed)
    // window.onload = function() {
    //     window.print();
    // };
</script>
<footer>© 2025 Gate Pass Management System | NFL Panipat</footer>
</body>
</html>
