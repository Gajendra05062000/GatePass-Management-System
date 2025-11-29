<%@ page language="java" import="java.util.*,java.sql.*,java.io.*,gatepass.Database"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE HTML>
<html>
<head>
<title>Foreigner Gate Pass - No <%= request.getParameter("srNo") %></title>
<meta charset="UTF-8">

<style>
/* Base Reset and Typography */
body {
    margin: 0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f0f4f7; /* Light background */
    color: #333;
}

/* Report Container (Full Report/Document Layout) */
.card {
    width: 100%;
    max-width: 850px; 
    padding: 35px;
    margin: 20px auto;
    border: 1px solid #cce;
    font-size: 14px;
    background-color: #fff;
    box-shadow: 0 8px 20px rgba(0,0,0,0.1); 
    border-radius: 12px;
}

/* --- REVISED PROFESSIONAL HEADER STRUCTURE --- */
.header-report {
    border-bottom: 3px solid #1e3c72; 
    padding-bottom: 15px;
    margin-bottom: 25px;
    display: flex;
    flex-wrap: wrap; 
    justify-content: space-between;
    align-items: center;
}
.logo-container {
    /* Adjusted container width */
    width: 110px; 
    text-align: center;
    flex-shrink: 0;
}
.logo-container img {
    /* 🚀 INCREASED LOGO SIZE FOR SCREEN VIEW */
    width: 100px; 
    height: 100px;
    display: block;
    margin: 0 auto;
    object-fit: contain;
}
.header-title-area {
    flex-grow: 1;
    text-align: center;
    padding: 0 10px;
}
.header-title-area h3 {
    margin: 0;
    font-size: 26px; /* Larger title */
    color: #1e3c72;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 700;
}
.header-title-area p {
    margin: 5px 0 0 0;
    font-size: 16px; /* Larger subtitle */
    color: #555;
    font-weight: 500;
}
/* --- END HEADER STRUCTURE --- */


/* --- NEW: METADATA TOP BLOCK (ID and Date) --- */
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
/* --- END METADATA BLOCK --- */


/* Photo & Data Layout (Matching Template's Flexbox) */
.content-top-section {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 20px;
    border-radius: 8px;
    padding: 15px;
    border: 1px solid #d4e8f7;
}

/* Photo container on the right */
.photo-container-right {
    flex-shrink: 0;
    padding-top: 5px;
    text-align: center;
}

.photo {
	margin-top:35px;
	margin-right:10px;
    width: 160px; /* Larger photo size */
    height: 200px;
    border: 4px solid #1e3c72; /* Official border */
    object-fit: cover;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    border-radius: 6px;
}

/* Data Table Styling (Matching Template's Table structure) */
.data-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 0px;
    border: none;
}

.data-table td {
    padding: 10px 15px;
    vertical-align: top;
    border-bottom: 1px dashed #ddd; /* Light separator */
}

/* Grouping Header (For Entry Details) */
.data-group-header {
    background-color: #e3f2fd; /* Light blue background for grouping */
    font-weight: bold;
    color: #1e3c72;
    padding: 8px 15px !important;
    border-bottom: 2px solid #1e3c72 !important;
    font-size: 16px;
    -webkit-print-color-adjust: exact;
    color-adjust: exact;
}

/* Field Names (First Column) */
.data-table td:first-child {
    font-weight: 600;
    color: #444;
    width: 30%; /* Set width for labels */
    background-color: #f7f7f7; /* Light shading for labels */
    -webkit-print-color-adjust: exact;
    color-adjust: exact;
}
/* Field Values (Second Column) */
.data-table td:nth-child(2) {
    color: #000;
    font-weight: 500;
    background-color: transparent !important;
}

/* Signature Area */
.signature-row {
    height: 60px; /* Space for signatures */
    border-top: 2px solid #ccc;
    margin-top: 40px;
    padding-top: 15px;
    display: flex;
    justify-content: space-between;
}

.signature-box {
    width: 45%;
    text-align: center;
    font-size: 14px;
    font-weight: 600;
    color: #333;
}

.signature-line {
    border-top: 1px solid #000;
    margin-bottom: 5px;
    height: 1px;
}

.instructions {
    font-size: 12px;
    margin-top: 30px;
    padding: 15px;
    border: 1px solid #1e3c72;
    background-color: #f0f5ff;
    border-radius: 4px;
    -webkit-print-color-adjust: exact;
    color-adjust: exact;
}

/* Print Control */
.print-container {
    text-align: center;
    margin-bottom: 20px;
}
.print-button {
    background-color: #007bff;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    transition: background-color 0.3s;
}

/* --- PRINT OPTIMIZATION --- */
@media print {
    .print-container { display: none; }
    body {
        background-color: white;
        padding: 0;
    }
    .card {
        box-shadow: none;
        border: none;
        width: 100%;
        max-width: none;
        margin: 0;
        padding: 0;
    }
    /* 🚀 INCREASED LOGO SIZE FOR PRINTING */
    .logo-container img {
        width: 90pt !important; 
        height: 90pt !important;
    }
    
    /* Ensure shaded backgrounds print */
    .data-table td:first-child, .data-group-header, .instructions, .content-top-section, .metadata-top-item {
        background-color: #f7f7f7 !important; /* Keep shading for print contrast */
        -webkit-print-color-adjust: exact;
        color-adjust: exact;
    }
    .metadata-top {
        /* Ensure dotted line prints correctly */
        border-top: 1pt dotted #888 !important; 
    }
    @page {
        size: A4;
        margin: 15mm;
    }

    footer {
        position: relative;
        margin-top: 30px;
    }
}
.data-table td.photo-cell {
    border-bottom: none !important;
}

footer {
  text-align: center;
  font-size: 10px;
  color: #777;
  margin-top: 30px;
  padding-top: 5px;
  border-top: 1px solid #eee;
}
</style>

<script>
function printPage() {
    const btn = document.getElementById("printPageButton");
    btn.style.display = 'none';
    window.print();
    btn.style.display = 'inline-block';
}

// Keeping the original popup function, although 'printPage' is now preferred for the button
function printPagePopUp(refNo) {
    const w = window.open(refNo, 'print', 'left=10,top=10,width=350,height=470');
    if (window.focus) w.focus();
    w.print();
}
</script>
</head>

<body>

<%
String srNo = request.getParameter("srNo");

// Get current date for "Issued On" field
java.time.LocalDateTime now = java.time.LocalDateTime.now();
// Using correct date pattern (dd-MMM-yyyy)
java.time.format.DateTimeFormatter dateFormatter = java.time.format.DateTimeFormatter.ofPattern("dd-MMM-yyyy"); 
String printDate = now.format(dateFormatter);

if (srNo == null || srNo.trim().isEmpty()) {
%>
<p style="color:red;text-align:center;">Error: Missing or invalid Gate Pass Serial Number.</p>
<%
} else {
	Database db = new Database();
	Connection conn = null;
	Statement st=null;
	ResultSet rs = null;
    try {
        conn = db.getConnection();
        st = conn.createStatement();
        String qry = "SELECT SER_NO,VISIT_DEPT,WORKSITE,NAME,FATHER_NAME,AGE,PHONE,LOCAL_ADDRESS,PERMANENT_ADDRESS,NATIONALITY,"
                   + "TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY'),TO_CHAR(VALIDITY_TO,'DD-MON-YYYY'),TO_CHAR(UPDATE_DATE,'DD-MON-YYYY'),IDCARD "
                   + "FROM GATEPASS_FOREIGNER WHERE SER_NO='" + srNo + "'";
        // System.out.println("Select all data from Qry--" + qry); // Kept original print statement commented out
        rs = st.executeQuery(qry);

        if (rs.next()) {
%>



<div class="card">
    <div class="header-report">
        <div class="logo-container">
            <img src="logo1.png" alt="NFL Logo">
        </div>

        <div class="header-title-area">
            <h3>FOREIGNER GATE PASS</h3>
            <p>CISF Gate Pass Management System | NFL Panipat</p>
        </div>

        <div class="logo-container">
            <img src="logo2.png" alt="CISF Logo">
        </div>
        
        <div class="metadata-top">
            <div class="metadata-top-item" style="margin-right: auto;">
                <strong>PASS NO:</strong>
                <span class="pass-number">NFL/CISF/FOREIGNER/0<%= rs.getString(1) %></span>
            </div>
            <div class="metadata-top-item" style="margin-left: auto;">
                <strong>Issued On:</strong>
                <%= printDate %>
            </div>
        </div>
        
    </div>
<div class="content-top-section">
    <div style="flex-grow: 1;">
        <table class="data-table">
            <tr>
                <td class="data-group-header" colspan="3">Foreigner Identification Details</td>
            </tr>

            <tr>
                <td>Name:</td>
                <td><%= rs.getString(4) %></td>

                <!-- PHOTO RIGHT SIDE WITH LABEL ABOVE -->
                <td rowspan="7" class="photo-cell" style="text-align:center; width:200px;">
                    
                    <img src="ShowImageForeigner.jsp?srNo=<%= rs.getString("SER_NO") %>" class="photo" alt="Foreigner Photo">
                </td>
            </tr>

            <tr>
                <td>Father Name:</td>
                <td><%= rs.getString(5) %></td>
            </tr>

            <tr>
                <td>Nationality:</td>
                <td><%= rs.getString(10) %></td>
            </tr>

            <tr>
                <td>Age:</td>
                <td><%= rs.getString(6) %></td>
            </tr>

            <tr>
                <td>Contact No.:</td>
                <td><%= rs.getString(7) %></td>
            </tr>

            <tr>
                <td>ID Card No.:</td>
                <td><%= rs.getString(14) %></td>
            </tr>

            <tr>
                <td>Permanent Address:</td>
                <td><%= rs.getString(9) %></td>
            </tr>
        </table>
    </div>
</div>

    <table class="data-table" style="margin-top: 25px; border: 1px solid #d4e8f7; border-radius: 8px; overflow: hidden;">
        <tr>
            <td class="data-group-header" colspan="2">Visit and Validity Details</td>
        </tr>
        <tr>
            <td>Visiting Department:</td>
            <td><%= rs.getString(2) %></td>
        </tr>
        <tr>
            <td>Work Site:</td>
            <td><%= rs.getString(3) %> (NFL, Panipat)</td>
        </tr>
        <tr>
            <td>Local Address:</td>
            <td><%= rs.getString(8) %></td>
        </tr>
        <tr>
            <td>Permanent Address:</td>
            <td><%= rs.getString(9) %></td>
        </tr>
        <tr>
            <td>Valid From / Upto:</td>
            <td><span style="color:green; font-weight: 600;">FROM: <%= rs.getString(11) %></span> <span style="color:red; margin-left: 15px;">TO: <%= rs.getString(12) %></span></td>
        </tr>
        <tr>
            <td>Date of Pass Generation:</td>
            <td><%= rs.getString(13) %></td>
        </tr>
    </table>

    <div class="signature-row">
        <div class="signature-box">
        <br><br>
            <div class="signature-line"></div>
            Signature of Card Holder
        </div>
        <div class="signature-box">
         <br><br>
            <div class="signature-line"></div>
            Issuing Authority Signature
        </div>
    </div>

    <div class="instructions">
        <b>Important Instructions:</b><br>
        1. This card must be produced before security staff on demand.<br>
        2. This card is non-transferable.<br>
        3. Loss of card must be reported immediately to the issuing authority.<br>
        4. The contractor does not guarantee employment. This only permits entry to the factory when required by the contractor.
    </div>
</div>

<%
        } else {
            out.println("<p style='color:red;text-align:center;'>No record found for Serial No: " + srNo + "</p>");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;text-align:center;'>Database Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}
%>
<div class="print-container">
    <button id="printPageButton" class="print-button" onclick="printPage()">🖨️ Print Foreigner Gate Pass</button>
</div>
<footer>Printed on <%= new java.util.Date() %> | © 2025 Gate Pass Management System | NFL Panipat</footer>
</body>
</html>