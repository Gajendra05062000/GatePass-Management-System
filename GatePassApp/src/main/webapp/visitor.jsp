<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.time.*, java.time.format.DateTimeFormatter,java.io.*,java.util.Base64,gatepass.CommonService,gatepass.Database"%>
<%@ page import="java.io.*"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.FileUploadException"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.io.output.*"%>
<html>
<head>
<title>Visitor Gate Pass</title>
<%
// ==========================================================
// 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
// ==========================================================
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
response.setDateHeader("Expires", 0); // Proxies.

// ==========================================================
// 🔑 SESSION AUTHENTICATION CHECK
// ==========================================================
if (session.getAttribute("username") == null) {
	response.sendRedirect("login.jsp");
	return;
}
%>
<!-- 🌈 Modern CSS Styling -->
<style>
/* Corporate Color Palette */
:root {
	--primary-navy: #1e3c72;
	--accent-blue: #007bff;
	--accent-red: #dc3545;
	--bg-light: #f8f9fa;
	--input-border: #ced4da;
	--shadow-light: 0 4px 12px rgba(0, 0, 0, 0.08);
}

body {
	font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
	background: var(--bg-light);
	margin: 0;
	padding: 30px;
}

.container {
	background-color: white;
	width: 95%;
	max-width: 1200px;
	margin: auto;
	padding: 30px 50px;
	border-radius: 15px;
	box-shadow: 0px 5px 25px rgba(0, 0, 0, 0.15);
	animation: fadeIn 1s ease;
}

@
keyframes fadeIn {from { opacity:0;
	transform: translateY(20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
h2 {
	text-align: center;
	color: var(--primary-navy);
	margin-bottom: 25px;
	font-weight: 700;
	border-bottom: 2px solid #e9ecef;
	padding-bottom: 10px;
}

/* --- Main Layout Grid --- */
.main-grid {
	display: grid;
	grid-template-columns: 2fr 1fr; /* Form (66%) and Camera (33%) */
	gap: 40px;
}

/* --- Form Layout and Inputs --- */
.form-grid {
	display: grid;
	grid-template-columns: repeat(2, 1fr); /* Two columns for fields */
	gap: 15px 30px;
}

.full-width {
	grid-column: span 2;
}

.input-group {
	display: flex;
	flex-direction: column;
}

label {
	font-weight: 600;
	color: #343a40;
	margin-bottom: 5px;
	font-size: 14px;
}

input[type="text"], input[type="date"], input[type="time"], select {
	/* Added select styling */
	padding: 10px 12px;
	border: 1px solid var(--input-border);
	border-radius: 6px;
	width: 100%;
	transition: 0.2s;
	background-color: var(--bg-light);
	box-sizing: border-box;
	appearance: none; /* Removes default dropdown arrow */
	-webkit-appearance: none;
	-moz-appearance: none;
}

input[type="text"]:focus, input[type="date"]:focus, input[type="time"]:focus,
	select:focus { /* Added select focus */
	border-color: var(--accent-blue);
	box-shadow: 0 0 5px rgba(0, 123, 255, 0.4);
	outline: none;
	background-color: white;
}

input[readonly] {
	background-color: #e9ecef !important;
	color: #6c757d;
}

/* --- Buttons --- */
.button-container {
	grid-column: span 2;
	text-align: center;
	padding-top: 15px;
	margin-top: 20px;
	border-top: 1px solid #eee;
}

button, input[type="submit"], input[type="reset"] {
	background-color: var(--primary-navy);
	border: none;
	color: white;
	padding: 10px 25px;
	font-size: 15px;
	font-weight: 600;
	border-radius: 6px;
	cursor: pointer;
	transition: 0.3s;
	margin: 0 8px;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

input[type="submit"] {
	background-color: var(--accent-blue);
}

input[type="submit"]:hover {
	background-color: #0056b3;
}

input[type="reset"] {
	background-color: var(--accent-red);
}

button:hover, input[type="reset"]:hover {
	background-color: #c82333;
	transform: translateY(-1px);
}

.camera-actions button {
	background-color: var(--accent-blue);
}

.camera-actions button:hover {
	background-color: #005fa3;
	transform: translateY(-1px);
}

/* --- Camera/Photo Area --- */
.video-container {
	text-align: center;
	background: var(--bg-light);
	border-radius: 10px;
	padding: 20px;
	box-shadow: var(--shadow-light);
	border: 1px solid #dcdcdc;
}

#video, #canvas, #photoPreview {
	border-radius: 8px;
	border: 3px solid var(--primary-navy);
	width: 100%;
	max-width: 320px;
	height: 240px;
	object-fit: cover;
	display: none;
	margin-bottom: 15px;
}

#video {
	display: block;
} /* Show video on load */
.camera-actions {
	display: flex;
	justify-content: center;
	gap: 10px;
}

/* Responsive adjustments */
@media ( max-width : 992px) {
	.main-grid {
		grid-template-columns: 1fr;
	}
	.form-grid {
		grid-template-columns: 1fr;
	}
	.full-width {
		grid-column: span 1;
	}
	.container {
		padding: 20px;
	}
}
/* Red asterisk styling */
.mandatory {
    color: var(--accent-red);
    margin-left: 4px;
}
.custom-alert {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 9999;
    padding: 15px 25px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    min-width: 300px;
    text-align: center;
    color: #fff;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    animation: fadeSlide 0.3s ease-out;
}

.custom-alert.error {
    background-color: #c0392b;
}

.custom-alert.success {
    background-color: #27ae60;
}

@keyframes fadeSlide {
    from { opacity: 0; top: 0px; }
    to { opacity: 1; top: 20px; }
}
</style>
<script> 
  let currentStream;
  let pincodeData = {};

  // Load JSON when page loads
  document.addEventListener("DOMContentLoaded", function() {
      loadPincodeData();
      openCamera();
  });
  
  function displayCustomAlert(message, type) {
	    const alertBox = document.getElementById("customAlertBox");

	    alertBox.innerHTML = message;
	    alertBox.className = "custom-alert " + type; 
	    alertBox.style.display = "block";

	    setTimeout(() => {
	        alertBox.style.display = "none";
	    }, 4000);
	}


  async function loadPincodeData() {
    try {
      // NOTE: This assumes 'pincode_database.json' is accessible at the root level.
      const response = await fetch("pincode_database.json");
      pincodeData = await response.json();
      console.log("✅ Pincode data loaded successfully");
    } catch (err) {
      console.error("❌ Failed to load pincode data", err);
      // Fallback message for user
      const pincodeInput = document.getElementById("pincode");
      if(pincodeInput) pincodeInput.placeholder = "Pincode auto-lookup disabled.";
    }
  }

  function fetchOfflinePincodeDetails() {
      const pincodeInput = document.getElementById("pincode");
      const pincode = pincodeInput.value.trim();
      const districtField = document.getElementById("district");
      const stateField = document.getElementById("state");

      districtField.value = "";
      stateField.value = "";

      if (pincode.length !== 6 || isNaN(pincode)) {
          displayCustomAlert("Please enter a valid 6-digit Pincode.", "error");
          return;
      }

      const details = pincodeData[pincode];
      if (details) {
          districtField.value = details.district.toUpperCase();
          stateField.value = details.state.toUpperCase();
      } else {
          displayCustomAlert("Pincode not found in local data. Please enter District/State manually.", "error");
      }
  }
  
  function openCamera() {
	  const video = document.getElementById("video");
	  const canvas = document.getElementById("canvas");
	  const previewImg = document.getElementById("photoPreview");
	  canvas.style.display = "none"; 
	  previewImg.style.display = "none"; 
	  video.style.display = "block"; 
      video.style.border = "3px solid var(--primary-navy)";

	  if (currentStream) {
          // Restart existing stream if available
          video.srcObject = currentStream;
          return;
      }
      
	  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
		  displayCustomAlert("Camera not supported in this browser.", "error");
		  return;
	  } 
      
	  navigator.mediaDevices.getUserMedia({ video: true }) 
          .then(stream => { 
		      currentStream = stream;
		      video.srcObject = stream;
		      video.play();
		  }) 
          .catch(err => { 
              displayCustomAlert("Error accessing camera. Please grant permissions: " + err.message, "error");
		  });
	  } 
      
  function capturePhoto() {
	  const video = document.getElementById("video");
	  const canvas = document.getElementById("canvas");
	  const previewImg = document.getElementById("photoPreview");
	  const context = canvas.getContext("2d");
      
      // Stop video feed
      if (currentStream) { 
          currentStream.getTracks().forEach(track => track.stop());
          currentStream = null;
      } 
      
      // Draw frame to canvas
	  context.drawImage(video, 0, 0, canvas.width, canvas.height);
	  
	  const dataUrl = canvas.toDataURL("image/png");
	  previewImg.src = dataUrl;
	  previewImg.style.display = "block";
	  video.style.display = "none";
	  canvas.style.display = "none";

	  // ✅ Save image to hidden field 
	  document.getElementById("imageData").value = dataUrl;
	  // Display custom success alert
	  displayCustomAlert("Photo captured successfully.", 'success');
	  } 
      
  function retakePhoto() { 
	  const previewImg = document.getElementById("photoPreview");
	  previewImg.style.display = "none"; 
      document.getElementById("imageData").value = ""; // Clear existing data
      openCamera();
	  } 
      
  function capLtr(value, id) {
	  const element = document.getElementById(id);
	  if (element) {
	  	element.value = value.toUpperCase();
	  }
  } 
      
  function validateForm() {
	    const imageData = document.getElementById("imageData").value;

	    if (!imageData || imageData.length < 50) {
	        displayCustomAlert("Please capture a photo before submitting!", "error");
	        return false;
	    }

	    const officerSelect = document.getElementById("officertomeet");
	    if (officerSelect.value === "") {
	        displayCustomAlert("Please select an officer.", "error");
	        return false;
	    }

	    return true;
	}

  </script>
<%
// --- Data Processing Block (Start) ---
if ("POST".equalsIgnoreCase(request.getMethod())) {
	int id = Integer.parseInt(request.getParameter("id"));
	String previd = request.getParameter("previousId");
	String name = request.getParameter("name");
	String fathername = request.getParameter("fathername");
	String address = request.getParameter("address");
	String vehicle = request.getParameter("vehicle");
	String district = request.getParameter("district");
	String state = request.getParameter("state");
	String pincode = request.getParameter("pincode");
	String telephone = request.getParameter("number");
	String material = request.getParameter("material");
	String officertomeet = request.getParameter("officertomeet"); // VALUE FROM SELECT FIELD
	String purpose = request.getParameter("purpose");
	String date = request.getParameter("date");
	String time = request.getParameter("time");
	System.out.println(time);
	String age = request.getParameter("age");
	String nationality = request.getParameter("nationality");
	String department = request.getParameter("department");
	String aadhar = request.getParameter("aadhar");

	java.sql.Date sqlDate = null;
	if (date != null && !date.isEmpty()) {
		sqlDate = java.sql.Date.valueOf(date);
	}


	// --- Database Insertion ---
	Connection conn = null;
	Statement st = null;
	ResultSet rs = null;
	File imageFile = null;

	try {
		Database db = new Database();
		conn = db.getConnection();

		// 2️⃣ Get last inserted record ID
		st = conn.createStatement();
		rs = null;

		

		// --- 3️⃣ Image Handling (Save to disk) ---
		String imageBase64 = request.getParameter("imageData");
		if (imageBase64 == null || imageBase64.trim().isEmpty()) {
	throw new Exception("Photo data is missing or invalid."); // Catch photo data earlier in validateForm()
		}

		if (imageBase64.startsWith("data:image"))
	imageBase64 = imageBase64.substring(imageBase64.indexOf(",") + 1);

		byte[] imageBytes = Base64.getDecoder().decode(imageBase64);

		String saveDir = "C:/GatepassImages/Visitor/";
		File folder = new File(saveDir);
		if (!folder.exists())
	folder.mkdirs();

		imageFile = new File(saveDir + "Visitor_" + id + ".png");

		try (FileOutputStream fos = new FileOutputStream(imageFile)) {
	fos.write(imageBytes);
		}
		System.out.println("📷 Image saved at: " + imageFile.getAbsolutePath());

		// 1️⃣ Insert data 
		// NOTE: Parameter indices 13, 14, 15, 19 need careful review against table definition.
		String sql = "INSERT INTO visitor(ID, NAME, FATHERNAME, ADDRESS, VEHICLE, DISTRICT, STATE, PINCODE, PHONE, MATERIAL, OFFICERTOMEET, PURPOSE, ENTRYDATE,TIME, IMAGE, \"AGE\", NATIONALITY, DEPARTMENT,ENTRYDATE1,AADHAR,PREVID) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		try (FileInputStream fis = new FileInputStream(imageFile)) {

	PreparedStatement ps = conn.prepareStatement(sql);

	ps.setInt(1, id);
	ps.setString(2, name);
	ps.setString(3, fathername);
	ps.setString(4, address);
	ps.setString(5, vehicle);
	ps.setString(6, district);
	ps.setString(7, state);
	ps.setString(8, pincode);
	ps.setString(9, telephone);
	ps.setString(10, material);
	ps.setString(11, officertomeet);
	ps.setString(12, purpose);
	ps.setDate(13, sqlDate); // ENTRYDATE
	ps.setString(14, time); // TIME
	ps.setBinaryStream(15, fis, (int) imageFile.length()); // IMAGE
	ps.setString(16, age); // AGE
	ps.setString(17, nationality); // NATIONALITY
	ps.setString(18, department); // DEPARTMENT
	ps.setDate(19, sqlDate); // ENTRYDATE1
	ps.setString(20, aadhar); // AADHAR
	ps.setString(21,previd);
	

	ps.executeUpdate();
	ps.close();

		}

		response.sendRedirect("print_visitor_card.jsp?id=" + id);
		return;

	} catch (Exception e) {
		out.println(
		"<p style='color:red;text-align:center; padding: 20px; font-weight: 600; background: #fff3f3; border: 1px solid #dc3545; border-radius: 8px;'>❌ Critical Error saving data: "
				+ e.getMessage() + "</p>");
		e.printStackTrace();
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
// --- Data Processing Block (End) ---
%>

<%
// --- Officer Selection Dropdown Generation ---
StringBuilder officerOptionsHtml = new StringBuilder();
Connection connOfficer = null;
Statement stOfficer = null;
ResultSet rsOfficer = null;

try {
	Database dbOfficer = new Database();
	connOfficer = dbOfficer.getConnection();

	String sql = "SELECT officers FROM officertomeet ORDER BY officers ASC";
	stOfficer = connOfficer.createStatement();
	rsOfficer = stOfficer.executeQuery(sql);

	officerOptionsHtml.append("<option value=\"\" selected disabled>-- Select Officer --</option>");

	while (rsOfficer.next()) {
		String officerName = rsOfficer.getString("officers");
		// Ensure the value and display text are correctly set
		officerOptionsHtml.append("<option value=\"").append(officerName).append("\">").append(officerName)
		.append("</option>");
	}

} catch (SQLException e) {
	officerOptionsHtml.append("<option value=\"\" disabled>⚠️ Error loading officers</option>");
	// This error will be logged in the console, not displayed to the user
} finally {
	if (rsOfficer != null)
		try {
	rsOfficer.close();
		} catch (SQLException ignore) {
		}
	if (stOfficer != null)
		try {
	stOfficer.close();
		} catch (SQLException ignore) {
		}
	if (connOfficer != null)
		try {
	connOfficer.close();
		} catch (SQLException ignore) {
		}
}
// --- End Officer Selection Dropdown Generation ---

// --- ID Initialization for Display ---
gatepass.Database db1 = new gatepass.Database();
Connection conn1 = null;
Statement st1 = null;
ResultSet rs1 = null;
int displayId = 1; // Default to 1, or the next calculated gap

try {
 // Assuming db1 is your Database object
    conn1 = db1.getConnection();
    st1 = conn1.createStatement();
    
    // 💡 SQL to find the lowest available ID (the first gap)
    String sqlFindGap = 
        "SELECT MIN(t1.ID + 1) " +
        "FROM VISITOR t1 " +
        "LEFT OUTER JOIN VISITOR t2 ON t1.ID + 1 = t2.ID " +
        "WHERE t2.ID IS NULL " +
        "AND t1.ID > 0";

    rs1 = st1.executeQuery(sqlFindGap);

    if (rs1.next()) {
        int nextGap = rs1.getInt(1);
        if (rs1.wasNull() || nextGap <= 0) {
            // This happens if the table is empty or the query couldn't find a gap above 0.
            // Fallback to MAX(ID) + 1 logic or just 1 if the table is truly empty.
            
            // Re-run the original query to safely get MAX + 1
            rs1.close(); // Close the previous ResultSet
            rs1 = st1.executeQuery("SELECT MAX(ID) FROM VISITOR");
            
            if (rs1.next()) {
                int maxId = rs1.getInt(1);
                // If the table is truly empty, maxId is 0 or null, so we start at 1.
                // Otherwise, we take MAX + 1.
                displayId = (rs1.wasNull() ? 1 : maxId + 1);
            }
        } else {
            // Found a gap (e.g., ID 3 is missing, so nextGap is 3)
            displayId = nextGap;
        }
    } else {
        // Should not happen if the query is correct, but safe fallback
        displayId = 1;
    }

} catch (SQLException e) {
    System.err.println("Database Error: " + e.getMessage());
} catch (Exception e) {
    System.err.println("General Error: " + e.getMessage());
} finally {
    // ⚠️ Crucial: Close Resources
    try { if (rs1 != null) rs1.close(); } catch (Exception ignored) {}
    try { if (st1 != null) st1.close(); } catch (Exception ignored) {}
    try { if (conn1 != null) conn1.close(); } catch (Exception ignored) {}
}

// The 'displayId' variable now holds the lowest available ID.

// --- Date/Time Initialization ---
LocalDate currentDate = LocalDate.now();
LocalTime currentTime = LocalTime.now();
String formattedDate = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
String formattedTime = currentTime.format(DateTimeFormatter.ofPattern("HH:mm:ss"));
%>
</head>
<body
	onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode}">

    <!-- Custom Message Box Container -->
    <div id="customAlertBox" style="display:none;" class="custom-alert"></div>
    
	<div class="container">
		<h2>VISITOR GATEPASS REGISTRATION</h2>
		<div class="main-grid">
			<!-- 📝 Left Form -->
			<div>
				<form action="visitor.jsp" method="post" name="text_form"
					onsubmit="return validateForm()">
					<!-- ✅ Hidden field to send Base64 image -->
					<input type="hidden" id="imageData" name="imageData">
					<div class="full-width">
                    <p style="font-size: 13px; color: #dc3545; font-weight: 600;">All Fields marked with (<span class="mandatory">*</span> ) are mandatory.</p>
                </div>

					<div class="form-grid">

						<div class="input-group">
							<label for="id">Visitor Gatepass No.<span class="mandatory">*</span></label> <input type="text"
								id="id" name="id" value="<%=displayId%>" readonly />
						</div>

						<div class="input-group">
							<label for="department">Visiting Department<span class="mandatory">*</span></label> <input
								type="text" id="department" name="department"
								onkeyup="capLtr(this.value,'department');" required/>
						</div>

						<div class="input-group">
							<label for="name">Name<span class="mandatory">*</span></label> <input type="text" id="name"
								name="name" onkeyup="capLtr(this.value,'name');" required />
						</div>

						<div class="input-group">
							<label for="fathername">Father Name<span class="mandatory">*</span></label> <input type="text"
								id="fathername" name="fathername"
								onkeyup="capLtr(this.value,'fathername');" required/>
						</div>

						<div class="input-group">
							<label for="age">Age<span class="mandatory">*</span></label> <input type="text" id="age"
								name="age" size="3" required/>
						</div>
						
						<div class="input-group">
                        <label>Aadhar Card No. <span class="mandatory">*</span></label>
                        <input type="text" id="aadhar" name="aadhar" maxlength="12" onkeypress="return /[0-9]/.test(event.key)" required/>
                    </div>

						<div class="input-group">
							<label for="nationality">Nationality<span class="mandatory">*</span></label> <input type="text"
								id="nationality" name="nationality" value="INDIAN"
								onkeyup="capLtr(this.value,'nationality');" readonly/>
						</div>

						<div class="input-group">
							<label for="address">Address<span class="mandatory">*</span></label> <input type="text"
								id="address" name="address"
								onkeyup="capLtr(this.value,'address');" required />
						</div>

						<div class="input-group">
							<label for="pincode">Pincode<span class="mandatory">*</span></label> <input type="text"
								id="pincode" name="pincode" maxlength="6"
								onchange="fetchOfflinePincodeDetails();" required/>
						</div>

						<div class="input-group">
							<label for="district">District<span class="mandatory">*</span></label> <input type="text"
								id="district" name="district"
								onkeyup="capLtr(this.value,'district');" required />
						</div>
						<div class="input-group">
    <label for="state">State<span class="mandatory">*</span></label>
    <select name="state" id="state" required>
        <option value="" disabled selected>-- Select State --</option>
        <% 
        String[] states = {
        	    "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh",
        	    "Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand",
        	    "Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur",
        	    "Meghalaya","Mizoram","Nagaland","Odisha","Punjab","Rajasthan",
        	    "Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh",
        	    "Uttarakhand","West Bengal", // 28 States
        	    "Andaman and Nicobar Islands","Chandigarh",
        	    "Dadra and Nagar Haveli and Daman and Diu","Delhi",
        	    "Jammu and Kashmir", // New UT
        	    "Ladakh", // New UT
        	    "Lakshadweep","Puducherry" // 8 Union Territories
        	};

            for (String s : states) {
        %>
        <option value="<%= s %>"><%= s %></option>
        <% } %>
    </select>
</div>


						<div class="input-group">
							<label for="number">Mobile/Telephone No.<span class="mandatory">*</span></label> <input type="text"
								id="number" name="number" maxlength="10" required/>
						</div>

						<div class="input-group">
							<label for="officertomeet">Officer to Meet</label>
							<!-- ✅ Replaced text input with dynamic SELECT dropdown -->
							<select id="officertomeet" name="officertomeet" required>
								<%=officerOptionsHtml.toString()%>
							</select>
						</div>

						<div class="input-group">
							<label for="material">Material/Item Carried</label> <input
								type="text" id="material" name="material" value="NIL"
								onkeyup="capLtr(this.value,'material');" />
						</div>

						<div class="input-group">
							<label for="vehicle">Vehicle Number (if any)</label> <input
								type="text" id="vehicle" name="vehicle"
								onkeyup="capLtr(this.value,'vehicle');" />
						</div>
						<div class="input-group">
							<label for="purpose">Purpose of Visit<span class="mandatory">*</span></label> <input type="text"
								id="purpose" name="purpose"
								onkeyup="capLtr(this.value,'purpose');" required />
						</div>

						<div class="input-group">
							<label for="date">Entry Date<span class="mandatory">*</span></label> <input type="date" id="date"
								name="date" value="<%=formattedDate%>" readonly />
						</div>

						<div class="input-group">
							<label for="time">Entry Time<span class="mandatory">*</span></label> <input type="time" id="time"
								name="time" value="<%=formattedTime%>" readonly />
						</div>



						<!-- Submit and Reset -->
						<div class="button-container">
							<input type="submit" value=" Submit Gatepass" /> <input
								type="reset" value="Clear Form" />
						</div>


					</div>
				</form>
			</div>

			<!-- 📷 Right Camera -->
			<div class="camera-column">
				<div class="video-container">
					<label>Visitor Photo Capture</label>
					<video id="video" width="320" height="240" autoplay style="display: none;"></video>
					<canvas id="canvas" width="320" height="240" style="display: none;"></canvas>
					<img id="photoPreview" alt="Captured Photo Preview" />

					<div class="camera-actions">
						<button type="button" onclick="capturePhoto()">&#128247;
							Capture</button>
						<button type="button" onclick="retakePhoto()">&#8635;
							Retake</button>
					</div>
				</div>
				<p
					style="text-align: center; color: #6c757d; margin-top: 10px; font-size: 13px;">Photo
					capture is mandatory for submission.</p>
			</div>
		</div>
	</div>
</body>
</html>