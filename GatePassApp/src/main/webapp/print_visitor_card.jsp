<%@ page import="java.sql.*,gatepass.Database"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Visitor Gate Pass Report - ID <%=request.getParameter("id")%></title>

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
	width: 100%; /* Take up most of the page width */
	max-width: 850px;
	padding: 35px;
	margin: 20px auto;
	border: 1px solid #cce;
	font-size: 14px;
	background-color: #fff;
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
	border-radius: 12px;
}

/* ------------------------------------------- */
/* --- 🚀 REVISED PROFESSIONAL HEADER STRUCTURE --- */
/* ------------------------------------------- */
.header-report {
	border-bottom: 3px solid #1e3c72;
	padding-bottom: 5px;
	margin-bottom: 10px;
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	flex-wrap: wrap;
}

.logo-container {
	/* Increased container width */
	width: 110px; 
	flex-shrink: 0;
	text-align: center;
}

.logo-container img {
	/* ➡️ INCREASED LOGO SIZE FOR SCREEN VIEW */
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
	font-size: 30px;
	color: #1e3c72;
	text-transform: uppercase;
	letter-spacing: 2px;
	font-weight: 800;
	line-height: 1.2;
}

.header-title-area p {
	margin: 5px 0 0 0;
	font-size: 16px;
	color: #555;
	font-weight: 500;
}

/* --- NEW: METADATA BLOCK for Pass No. and Date --- */
.metadata-block {
	width: 100%;
	display: flex;
	justify-content: space-between;
	padding: 10px 0;
	margin-top: 10px;
	border-top: 1px dashed #ccc;
}

.metadata-item {
	font-size: 13px;
	font-weight: 600;
	color: #333;
	padding: 0 5px;
}

.metadata-item strong {
	color: #1e3c72;
	margin-right: 5px;
}

.metadata-item .pass-number {
	font-size: 16px;
	font-weight: 800;
	color: #cc0000;
}

/* --- END HEADER STRUCTURE --- */

/* Photo & Signature Section */
.content-top-section {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 20px;
	padding: 15px;
	border: 1px solid #d4e8f7;
	border-radius: 8px;
	gap: 20px;
}


.photo-container-right {
	flex-shrink: 0;

	padding-top: 5px;
}

.photo {

	width: 160px;
	height: 200px;
	border: 4px solid #1e3c72;
	object-fit: cover;

	border-radius: 6px;
}

/* Data Table Styling */
.data-table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 15px;
}

.data-table td {
	    padding: 10px 0px 10px 10px;
	vertical-align: top;
	border-bottom: 1px dashed #ddd;
}

/* Grouping Header (For Entry Details) */
.data-group-header {
	background-color: #e3f2fd;
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
	width: 25%;
	background-color: #f7f7f7;
	-webkit-print-color-adjust: exact;
	color-adjust: exact;
}
/* Field Values (Second Column) */
.data-table td:nth-child(2) {
	color: #000;
	font-weight: 500;
}

/* Signature Area */
.signature-row {
	height: 60px;
	border-top: 2px solid #ccc; 
	margin-top: 40px;
	padding-top: 15px;
	display: flex;
	justify-content: space-between;
}

.signature-box {
	width: 30%;
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

/* --- PRINT OPTIMIZATION (A5 friendly) --- */
@media print {
	.print-container {
		display: none;
	}
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
	/* Ensure shaded backgrounds print */
	.data-table td:first-child, .data-group-header, .instructions,
		.content-top-section {
		background-color: #f7f7f7 !important;
		-webkit-print-color-adjust: exact;
		color-adjust: exact;
	}
	/* ➡️ INCREASED LOGO SIZE FOR PRINTING */
	.logo-container img {
		width: 90pt !important; 
		height: 90pt !important;
	}
	
	/* Adjust header text size for A5 legibility */
	.header-title-area h3 {
		font-size: 20pt !important; 
	}
	.header-title-area p {
		font-size: 10pt !important;
	}
	
	.metadata-item {
	    font-size: 10pt !important;
	}
	.metadata-item .pass-number {
	    font-size: 13pt !important;
	}
	
	@page {
		size: A5 portrait; /* Target A5 size */
		margin: 10mm;
	}
	footer {
		position: relative;
		margin-top: 30px;
	}
}

footer {
	text-align: center;
	font-size: 10px;
	color: #777;
	margin-top: 30px;
	padding-top: 5px;
	border-top: 1px solid #eee;
}
 @media print {
    @page {
      size: A5;
      margin: 10mm;
    }

    body {
      
    }

    .print-button {
      display: none !important; /* Hide print button during printing */
    }
  }
</style>
<script>
	function printPage() {
		const btn = document.getElementById("printPageButton");
		btn.style.display = 'none';
		window.print();
		btn.style.display = 'inline-block';
	}
</script>
</head>

<body>
	<%
	String id = request.getParameter("id");
	
	// Get current date for "Issued On" field
	LocalDateTime now = LocalDateTime.now();
	// Corrected date format pattern
	DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd-MMM-yyyy"); 
	String printDate = now.format(dateFormatter);

	if (id == null || id.trim().isEmpty()) {
	%>
	<p style="color: red; text-align: center;">Error: Missing or
		invalid Visitor Pass Number</p>
	<%
	} else {
	Connection conn = null;
	Statement st = null;
	ResultSet rs = null;
	try {
		Database db = new Database();
		conn = db.getConnection();
		st = conn.createStatement();

		String query = "SELECT NAME, FATHERNAME, TO_CHAR(ENTRYDATE, 'DD-MON-YYYY') AS ENTRYDATE, VEHICLE, DISTRICT, STATE, PINCODE, PHONE, PURPOSE, "
		+ "TO_CHAR(SYSDATE, 'DD-MON-YYYY') AS CURR_DATE,AGE , TIME,OFFICERTOMEET,AADHAR " + "FROM visitor WHERE ID=" + id;

		rs = st.executeQuery(query);
		if (rs.next()) {
	%>


	<div class="card">
		<div class="header-report">
			<div class="logo-container">
				<img src="logo1.png" alt="NFL Logo">
			</div>

			<div class="header-title-area">
				<h3>VISITOR GATE PASS</h3>
				<p>CISF Gate Pass Management System
				</p>
				<p> NFL Panipat Unit</p>
			</div>

			<div class="logo-container">
				<img src="logo2.png" alt="CISF Logo">
			</div>
			
			<div class="metadata-block">
			    <div class="metadata-item">
				    <strong>VISITOR PASS NO:</strong>
				    <span class="pass-number">NFL/CISF/VISITOR/0<%=id%></span>
				</div>
				<div class="metadata-item">
				    <strong>ISSUED ON:</strong>
				    <%= rs.getString("ENTRYDATE")%>
				</div>
			</div>
			
		</div>
		<div class="content-top-section">
	<div style="flex: 1;">
		<table class="data-table">
	<tr>
		<td class="data-group-header" colspan="3">Visitor Identification Details</td>
	</tr>

	<tr>
		<td>Name:</td>
		<td><%=rs.getString("NAME")%></td>
		
		<!-- First row showing heading above image -->
		<td rowspan="5" style="text-align:center; width:200px;">
			
			<img src="ShowVisitor.jsp?id=<%=id%>" class="photo" alt="Visitor Photo">
		</td>
	</tr>

	<tr>
		<td>Father Name:</td>
		<td><%=rs.getString("FATHERNAME")%></td>
	</tr>

	<tr>
		<td>Age:</td>
		<td><%=rs.getString("AGE")%></td>
	</tr>

	<tr>
		<td>Contact No:</td>
		<td><%=rs.getString("PHONE")%></td>
	</tr>

	<tr>
		<td>Aadhar Card No:</td>
		<td><%=rs.getString("AADHAR")%></td>
	</tr>
</table>

	</div>

	
</div>


		<table class="data-table"
			style="margin-top: 25px; border: 1px solid #d4e8f7; border-radius: 8px; overflow: hidden;">
			<tr>
				<td class="data-group-header" colspan="2">Entry and Purpose
					Details</td>
			</tr>
			<tr>
				<td>Officer To Meet:</td>
				<td><%=rs.getString("OFFICERTOMEET")%></td>
			</tr>
			<tr>
				<td>Address:</td>
				<td><%=rs.getString("DISTRICT")%>, <%=rs.getString("STATE")%>
					- <%=rs.getString("PINCODE")%></td>
			</tr>
			<tr>
				<td>Vehicle No:</td>
				<td><%=rs.getString("VEHICLE")%></td>
			</tr>
			<tr>
				<td>Entry Date/Time:</td>
				<td><%=rs.getString("ENTRYDATE")%> at <%=rs.getString("TIME")%></td>
			</tr>
			<tr>
				<td>Purpose of Visit:</td>
				<td><%=rs.getString("PURPOSE")%></td>
			</tr>
		</table>

		<div class="signature-row">
			<div class="signature-box">
				<br>
				<br>
				<div class="signature-line"></div>
				Signature of Visitor
			</div>&nbsp;
			<div class="signature-box">
				<br>
				<br>
				<div class="signature-line"></div>
				Signature of Officer Whom to Meet
			</div>&nbsp;
			<div class="signature-box">
				<br>
				<br>
				<div class="signature-line"></div>
				Signature of Issuing Authority
			</div>
		</div>

		<div class="instructions">
			<b>Important Instructions:</b><br> 1. This pass must be shown to
			security staff on demand.<br> 2. This pass is non-transferable
			and valid only for the specified period.<br> 3. Report loss or
			damage immediately to the issuing authority.
		</div>
	</div>
	<div class="print-container">
		<button id="printPageButton" class="print-button"
			onclick="printPage()">🖨️ Print Visitor Gate Pass</button>
	</div>

	<%
	} else {
	out.println("<p style='color:red;text-align:center;'>Record Not Found</p>");
	}
	} catch (SQLException e) {
	out.println("<p style='color:red;text-align:center;'>Database Error: " + e.getMessage() + "</p>");
	} finally {
	if (rs != null)
	try {
		rs.close();
	} catch (SQLException ignore) {
	}
	if (st != null)
	try {
		st.close();
	} catch (SQLException ignore) {
	}
	if (conn != null)
	try {
		conn.close();
	} catch (SQLException ignore) {
	}
	}
	}
	%>
	<footer>
		Printed on
		<%=new java.util.Date()%>
		| © 2025 Gate Pass Management System | NFL Panipat
	</footer>
</body>
</html>