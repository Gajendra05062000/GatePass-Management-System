<%@ page import="java.sql.*,gatepass.Database" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Contract Registration Pass</title>

<style>
/* Base Reset and Typography */
body {
    margin: 0;
    padding: 20px;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f0f4f7; /* Light background */
    color: #333;
}

/* Report Container (Full Report/Document Layout) */
.pass-container {
    width: 95%; 
    max-width: 900px; 
    padding: 30px;
    margin: 20px auto;
    border: 1px solid #cce;
    font-size: 16px; 
    background-color: #fff;
    box-shadow: 0 8px 20px rgba(0,0,0,0.1); 
    border-radius: 12px;
}

/* --- PROFESSIONAL HEADER STRUCTURE (Dual Logo) --- */
.header-report {
    /* Main solid line below the titles/logos */
    border-bottom: 3px solid #1e3c72; 
    padding-bottom: 15px;
    margin-bottom: 25px;
    
    display: flex;
    flex-wrap: wrap; 
    justify-content: space-between; 
    align-items: center;
}
.logo-container {
    width: 110px; 
    text-align: center;
    flex-shrink: 0;
}
.logo-container img {
    /* INCREASED LOGO SIZE FOR SCREEN VIEW */
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
    font-size: 26px; 
    color: #1e3c72;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 700;
}
.header-title-area p {
    margin: 5px 0 0 0;
    font-size: 16px; 
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
    
    /* Removed redundant border-bottom from previous version */
    /* border-bottom: none; */ 
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

/* Data Table Styling */
.data-table {
    width: 100%;
    border-collapse: collapse;
    /* Removed top margin since the metadata block already provides separation */
    margin-top: 0; 
    border: 1px solid #d4e8f7; 
    border-radius: 8px;
    overflow: hidden;
}

.data-table td {
    padding: 12px 15px; 
    vertical-align: top;
    border-bottom: 1px dashed #ddd; 
}

/* Grouping Header */
.data-group-header {
    background-color: #e3f2fd !important; 
    font-weight: bold;
    color: #1e3c72;
    padding: 10px 15px !important; 
    border-bottom: 2px solid #1e3c72 !important;
    font-size: 18px; 
    -webkit-print-color-adjust: exact;
    color-adjust: exact;
}

/* Field Names (First Column of any pair) */
.data-table td:nth-child(odd) {
    font-weight: 600;
    color: #444;
    width: 25%; 
    background-color: #f7f7f7; 
    -webkit-print-color-adjust: exact;
    color-adjust: exact;
}
/* Field Values (Second Column of any pair) */
.data-table td:nth-child(even) {
    color: #000;
    font-weight: 500;
    width: 25%; 
}

/* * --- SIGNATURE AREA STYLING --- */
.signature-area {
    margin-top: 50px; 
    padding-top: 20px;
    
    display: flex;
    justify-content: space-around; 
    align-items: flex-end; 
    border-top: 2px solid #ccc; 
}

.signature-area > div { 
    text-align: center;
    font-size: 16px; 
    font-weight: 600;
    color: #333;
    width: 45%; 
}

.signature-line {
    border-top: 1px solid #000;
    margin-bottom: 5px; 
    height: 1px;
}

/* --- NEW INSTRUCTIONS AREA STYLING --- */
.instructions-area {
    margin-top: 40px;
    padding: 20px;
    border: 1px solid #1e3c72; 
    border-radius: 8px;
    background-color: #fff3e0; 
}

.instructions-area h4 {
    margin-top: 0;
    color: #e65100; 
    font-size: 18px;
    border-bottom: 1px solid #e65100;
    padding-bottom: 5px;
    margin-bottom: 10px;
}

.instructions-area ul {
    list-style-type: disc;
    padding-left: 25px;
    margin: 0;
    font-size: 14px;
    line-height: 1.6;
}

.instructions-area ul li {
    margin-bottom: 5px;
    color: #333;
}
/* --- END INSTRUCTIONS AREA STYLING --- */


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

/* --- A4 PRINT OPTIMIZATION --- */
@media print {
    /* Set page to A4 and define small margins */
    @page { 
        size: A4; 
        margin: 15mm; 
    }
    
    body {
        background: white;
        padding: 0;
        margin: 0;
    }

    .pass-container {
        width: 100%; 
        max-width: none;
        box-shadow: none;
        border: none; 
        margin: 0;
        padding: 0;
    }
    
    /* Ensure shaded backgrounds print */
    .data-table td:nth-child(odd), .data-group-header, .metadata-top-item {
        background-color: #f7f7f7 !important; 
        -webkit-print-color-adjust: exact;
        color-adjust: exact;
    }

    .print-container {
        display: none !important;
    }
    
    /* INCREASED LOGO SIZE FOR PRINTING */
    .logo-container img {
        width: 90pt !important; 
        height: 90pt !important;
    }
    
    .metadata-top {
        /* Adjusted padding/margin for print */
        padding-top: 10pt;
        margin-top: 10pt;
        /* Ensure dotted line prints correctly */
        border-top: 1pt dotted #888 !important; 
    }
    .metadata-top-item {
        font-size: 10pt;
        padding: 6pt 10pt;
    }
    .metadata-top-item .pass-number {
        font-size: 12pt;
    }

    footer {
        position: relative;
        margin-top: 30px;
    }
}

footer {
  text-align: center;
  font-size: 12px;
  color: #777;
  margin-top: 30px;
  padding-top: 10px;
  border-top: 1px solid #eee;
}
</style>
<script>
function printPage() {
    const container = document.querySelector(".print-container");
    container.style.display = 'none';
    window.print();
    container.style.display = 'block';
}

function loadPrintPageInMainFrame(ID) { 
	  const url = "PrintForeignerGatePass.jsp?srNo=" + ID;
	  
	  if (window.parent && window.parent.right) {
	    window.parent.right.location.href = url;
	  } else {
	    alert("Could not load the print page in the main content frame. Loading in current window.");
	    window.location.href = url;
	  }
	}
</script>
</head>

<body>
<%
String id = request.getParameter("id");

// Get current date for "Issued On" field
java.time.LocalDateTime now = java.time.LocalDateTime.now();
// Using correct date pattern (dd-MMM-yyyy)
java.time.format.DateTimeFormatter dateFormatter = java.time.format.DateTimeFormatter.ofPattern("dd-MMM-yyyy"); 
String printDate = now.format(dateFormatter);

if(id == null || id.trim().isEmpty()) {
%>
<p style="color:red; text-align:center;">Error: Missing or invalid Contract Registration ID</p>
<%
} else {
    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;
    try {
        Database db = new Database();
        conn = db.getConnection();
        st = conn.createStatement();

        String query = "SELECT TO_CHAR(UPDATE_DATE,'DD-MON-YYYY'),ID, CONTRACT_NAME, CONTRACTOR_NAME, DEPARTMENT, CONTRACTOR_ADDRESS, WORKSITE, DESCRIPTION, CONTRACTOR_ADHAR, TO_CHAR(VALIDITY_FROM,'DD-MON-YYYY') AS VALIDITY_FROM, TO_CHAR(VALIDITY_TO,'DD-MON-YYYY') AS VALIDITY_TO, CONTRACT_TYPE, REGISTRATION,LABOUR_SIZE,PHONE " +
                       "FROM GATEPASS_CONTRACT WHERE ID=" + id;

        rs = st.executeQuery(query);
        if(rs.next()) {
%>



<div class="pass-container">
    <div class="header-report">
        
        <div class="logo-container">
            <img src="logo1.png" alt="NFL Logo">
        </div>

        <div class="header-title-area">
            <h3>CONTRACT REGISTRATION</h3>
            <p>CISF Gate Pass Management System | NFL Panipat</p>
        </div>

        <div class="logo-container">
            <img src="logo2.png" alt="CISF Logo">
        </div>
        
        <div class="metadata-top">
            <div class="metadata-top-item" style="margin-right: auto;">
                <strong>Contract Registration No:</strong>
                <span class="pass-number">NFL/CISF/CONTRACT/0<%= id %></span>
            </div>
            <div class="metadata-top-item" style="margin-left: auto;">
                <strong>Issued On:</strong>
                <%= rs.getString(1) %>
            </div>
        </div>
        
    </div>

    <table class="data-table">
        <tr>
            <td class="data-group-header" colspan="4">Contract Validity and Description</td>
        </tr>
    	
        <tr>
            <td>Contract Name:</td>
            <td><%= rs.getString("CONTRACT_NAME") %></td>
            <td>Contract Type:</td>
            <td><%= rs.getString("CONTRACT_TYPE") %></td>
        </tr>
        <tr>
            
            <td>Reg. No:</td>
            <td><%= rs.getString("REGISTRATION") %></td>
            <td>Department:</td>
            <td><%= rs.getString("DEPARTMENT") %></td>
        </tr>
        <tr>
            
            
            <td>Labour Size:</td>
            <td><%= rs.getString("LABOUR_SIZE") %></td>
            <td style="width: 15%; background-color: #f7f7f7 !important;">Description:</td>
            <td colspan="3"><%= rs.getString("DESCRIPTION") %></td></tr>
        </tr>
        
        <tr>
            <td><span style="color:green;">Valid From:</span></td>
            <td><span class="field-highlight" style="color:green;"><%= rs.getString("VALIDITY_FROM") %></span></td>
            <td><span style="color:red;">Valid To:</span></td>
            <td><span class="field-highlight" style="color:red;"><%= rs.getString("VALIDITY_TO") %></span></td>


        <tr>
            <td colspan="4" class="data-group-header">Contractor Details</td>
        </tr>
        <tr>
            <td>Contractor Name:</td>
            <td><%= rs.getString("CONTRACTOR_NAME") %></td>
            <td>Contractor Aadhar No:</td>
            <td><%= rs.getString("CONTRACTOR_ADHAR") %></td>
        </tr>
        <tr>
        <td>Contractor Contact No:</td>
            <td><%= rs.getString("PHONE") %></td>
            <td>Contractor Address:</td>
            <td><%= rs.getString("CONTRACTOR_ADDRESS") %></td>
        </tr>
    </table>

    <div class="signature-area">
        <div><br>
            <div class="signature-line"></div>
            Contractor/Card Holder Sign

        </div>
        <div><br> 
            <div class="signature-line"></div>
            Issuing Authority Sign
        </div>
    </div>
    
    <div class="instructions-area">
        <h4>🚨 Important Instructions</h4>
        <ul>
            <li>This document serves as proof of contract registration with **NFL Panipat** for the mentioned contractor and contract name.</li>
            <li>The registration is valid only between the dates specified in the **"Valid From"** and **"Valid To"** fields.</li>
            <li>Entry to the plant premises is strictly regulated by **CISF personnel** and requires a valid Gate Pass, which is issued based on this registration.</li>
            <li>Any change in work scope, contractor details, or validity must be officially registered and updated in the system.</li>
            <li>The contractor must ensure all personnel working under this contract possess valid individual Gate Passes at all times.</li>
            <li>Violation of safety or security norms will lead to **immediate cancellation** of this contract registration and further action.</li>
        </ul>
    </div>
    </div>
<div class="print-container">
    <button id="printPageButton" class="print-button" onclick="printPage()">🖨️ Print Contract Registration</button>
</div>
<%
    } else {
        out.println("<p style='color:red;text-align:center;'>Record Not Found for ID: " + id + "</p>");
    }
    } catch (SQLException e) {
        out.println("<p style='color:red;text-align:center;'>Database Error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (st != null) try { st.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
}
%>
<footer>Printed on <%= new java.util.Date() %> | © 2025 Gate Pass Management System | NFL Panipat</footer>
</body>
</html>