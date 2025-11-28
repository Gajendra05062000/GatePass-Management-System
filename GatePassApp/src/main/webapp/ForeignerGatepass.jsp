<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, gatepass.Database"%>
<%@ page import="java.io.*"%>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter"%>

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

<%
// --- 1. Get Next Serial Number for Display ---
gatepass.Database db = new gatepass.Database();
Connection connId = null;
Statement stId = null;
ResultSet rsId = null;
int nextSrNo = 1;

try {
	connId = db.getConnection();
	stId = connId.createStatement();
	rsId = stId.executeQuery("SELECT MAX(SER_NO) FROM GATEPASS_FOREIGNER");
	if (rsId.next()) {
		int maxId = rsId.getInt(1);
		nextSrNo = rsId.wasNull() ? 1 : maxId + 1;
	}
} catch (SQLException e) {
	System.err.println("Database error generating Sr. No.: " + e.getMessage());
} finally {
	if (rsId != null)
		try {
	rsId.close();
		} catch (SQLException ignore) {
		}
	if (stId != null)
		try {
	stId.close();
		} catch (SQLException ignore) {
		}
	if (connId != null)
		try {
	connId.close();
		} catch (SQLException ignore) {
		}
}

// --- 2. Dynamic Officer Dropdown Generation ---
StringBuilder officerOptionsHtml = new StringBuilder();
Connection connOfficer = null;
Statement stOfficer = null;
ResultSet rsOfficer = null;

try {
	connOfficer = db.getConnection();
	String sql = "SELECT officers FROM officertomeet ORDER BY officers ASC";
	stOfficer = connOfficer.createStatement();
	rsOfficer = stOfficer.executeQuery(sql);

	officerOptionsHtml.append("<option value=\"\" selected disabled>-- Select Officer --</option>");

	while (rsOfficer.next()) {
		String officerName = rsOfficer.getString("officers");
		officerOptionsHtml.append("<option value=\"").append(officerName).append("\">").append(officerName)
		.append("</option>");
	}

} catch (SQLException e) {
	officerOptionsHtml.append("<option value=\"\" disabled>⚠️ Error loading officers</option>");
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

// --- 3. Date Initialization ---
LocalDate currentDate = LocalDate.now();
String formattedDate = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
%>
<head>
<title>Foreigner Gate Pass</title>

<!-- 🌈 Modern CSS Styling (Matching Visitor Form) -->
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
keyframes fadeIn { from { opacity:0;
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

/* Red asterisk styling */
.mandatory {
    color: var(--accent-red);
    margin-left: 4px;
}

input[type="text"], input[type="date"], select {
	/* Style for select dropdowns */
	padding: 10px 12px;
	border: 1px solid var(--input-border);
	border-radius: 6px;
	width: 100%;
	transition: 0.2s;
	background-color: var(--bg-light);
	box-sizing: border-box;
}

input[type="text"]:focus, input[type="date"]:focus, select:focus {
	border-color: var(--accent-blue);
	box-shadow: 0 0 5px rgba(0, 123, 255, 0.4);
	outline: none;
	background-color: white;
}

input[readonly] {
	background-color: #e9ecef !important;
	color: #6c757d;
}

/* Specific styling for the validity date range group */
.validity-group {
	display: flex;
	gap: 15px;
}

.validity-group>div {
	flex: 1;
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
}

.camera-actions {
	display: flex;
	justify-content: center;
	gap: 10px;
}

/* Custom Alert Box Styles */
.custom-alert {
	position: fixed;
	top: 20px;
	left: 50%;
	transform: translateX(-50%);
	z-index: 2000;
	padding: 15px 30px;
	border-radius: 8px;
	font-weight: bold;
	color: red;
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
	text-align: center;
	min-width: 300px;
	animation: slideDown 0.3s ease-out;
}

.custom-alert.error {
	background-color: var(--accent-red);
	border: 1px solid #e74c3c;
}

@
keyframes slideDown { from { top:-60px;
	opacity: 0;
}

to {
	top: 20px;
	opacity: 1;
}

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
	.validity-group {
		flex-direction: column;
	}
}
</style>
<script> 
  let currentStream;

  document.addEventListener("DOMContentLoaded", function() {
      openCamera();
  });
  
  function openCamera() {
	  const video = document.getElementById("video");
	  const canvas = document.getElementById("canvas");
	  const previewImg = document.getElementById("photoPreview");
	  canvas.style.display = "none"; 
	  previewImg.style.display = "none"; 
	  video.style.display = "block"; 
      video.style.border = "3px solid var(--primary-navy)";

	  if (currentStream) {
          video.srcObject = currentStream;
          video.play();
          return;
      }
      
	  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
		  console.error("Camera not supported in this browser.");
		  return;
	  } 
      
	  navigator.mediaDevices.getUserMedia({ video: true }) 
          .then(stream => { 
		      currentStream = stream;
		      video.srcObject = stream;
		      video.play();
		  }) 
          .catch(err => { 
              displayCustomAlert("Error accessing camera: " + err.message + ". Permissions may be blocked.", 'error');
		  });
	  } 
      
  function capturePhoto() {
	  const video = document.getElementById("video");
	  const canvas = document.getElementById("canvas");
	  const previewImg = document.getElementById("photoPreview");

      if (video.style.display === 'none' || video.paused) {
          displayCustomAlert("Camera stream not active. Please click Retake.", 'error');
          return; 
      }
      
	  const context = canvas.getContext("2d");
	  context.drawImage(video, 0, 0, canvas.width, canvas.height);
	  
	  if (currentStream) { 
          currentStream.getTracks().forEach(track => track.stop());
          currentStream = null;
	  } 
      
	  const dataUrl = canvas.toDataURL("image/png");
	  previewImg.src = dataUrl;
	  previewImg.style.display = "block";
	  video.style.display = "none";
	  canvas.style.display = "none";
	  
	  document.getElementById("imageData").value = dataUrl;
	  displayCustomAlert("Photo captured successfully.", 'success');
	  } 
      
  function retakePhoto() { 
	  const previewImg = document.getElementById("photoPreview");
	  previewImg.style.display = "none"; 
      document.getElementById("imageData").value = ""; 
      openCamera();
	  } 
      
  function capLtr(value, id) {
	  const input = document.getElementById(id);
      if (input) {
	      input.value = value.toUpperCase();
      }
	  } 
  
  function displayCustomAlert(message, type) {
	    const alertBox = document.getElementById('customAlertBox');
	    if (type === 'error') {
	        alertBox.style.color = 'white';
	        alertBox.style.backgroundColor = 'var(--accent-red)';
	        alertBox.style.borderColor = '#c82333';
	    } else {
	        // Style for success
	        alertBox.style.color = 'green';
	        alertBox.style.backgroundColor = '#d4edda';
	        alertBox.style.borderColor = '#c3e6cb';
	    }
	    alertBox.innerHTML = message;
	    alertBox.className = 'custom-alert ' + type;
	    alertBox.style.display = 'block';

	    setTimeout(() => {
	        alertBox.style.display = 'none';
	    }, 4000);
	}


	function ValidateDates(form) {
	    const fromDateStr = form.valdity_fromDate.value;
	    const toDateStr = form.valdity_toDate.value;

	    if (fromDateStr === "" || toDateStr === "") {
	        return true; // Let browser handle 'required' attribute 
	    }

	    const fromDate = new Date(fromDateStr);
	    const toDate = new Date(toDateStr);

	    if (fromDate > toDate) {
	        const msg = "The 'Valid From' date cannot be later than the 'Valid To' date.";
	        displayCustomAlert(msg, 'error');
	        return false;
	    }
	    
	    return true; 
	}
  
  function validateForm(form) {
      // 1. Photo Check
	  const imageData = document.getElementById("imageData").value;
	  if (!imageData) { 
          displayCustomAlert("Please capture a photo before submitting!", 'error');
	      return false; 
	  }
	  
	  // 2. Officer Check
	  const officerSelect = document.getElementById("officerToMeet");
	  if (officerSelect && officerSelect.value === "") {
          displayCustomAlert("Please select the Officer to Meet.", 'error');
	      return false;
	  }
	  
      // 3. Date Range Check
	  return ValidateDates(form); 
  } 
  
  </script>
</head>
<body>
	<!-- Custom Message Box Container -->
	<div id="customAlertBox" style="display: none;" class="custom-alert"></div>

	<div class="container">
		<h2>FOREIGNER GATE PASS REGISTRATION</h2>
		<div class="main-grid">
			<!-- 📝 Left Form -->
			<div>
				<!-- ACTION MUST BE A SERVLET/HANDLER for image processing -->
				<form action="SaveForeignerGatePasData" method="post"
					name="text_form" onsubmit="return validateForm(this)">
					<!-- ✅ Hidden field to send Base64 image -->
					<input type="hidden" id="imageData" name="imageData">
					<div class="full-width">
						<p
							style="font-size: 13px; color: #dc3545; font-weight: 600;">All
							Fields marked with (<span class="mandatory">*</span> ) are
							mandatory.
						</p>
					</div>

					<div class="form-grid">

						<div class="input-group">
							<label for="srNo">Foreign Pass No.<span class="mandatory">*</span></label>
							<input type="text" id="srNo" name="srNo" value="<%=nextSrNo%>"
								readonly />
						</div>

						<div class="input-group">
							<label for="workSite">Work Site<span class="mandatory">*</span></label>
							<input type="text" id="workSite" name="workSite"
								value="NFL, PANIPAT" readonly />
						</div>

						<div class="input-group">
							<label for="visitingDept">Visiting Department<span
								class="mandatory">*</span></label> <input type="text"
								id="visitingDept" name="visitingDept" required
								onkeyup="capLtr(this.value,'visitingDept');" />
						</div>

						<div class="input-group">
							<label for="name">Name<span class="mandatory">*</span></label> <input
								type="text" id="name" name="name" required
								onkeyup="capLtr(this.value,'name');" />
						</div>

						<div class="input-group">
							<label for="fatherName">Father Name<span class="mandatory">*</span></label>
							<input type="text" id="fatherName" name="fatherName" required
								onkeyup="capLtr(this.value,'fatherName');" />
						</div>


						<div class="input-group">
							<label for="age">Age<span class="mandatory">*</span></label> <input
								type="text" id="age" name="age" maxlength="3" required
								onkeypress="return /[0-9]/.test(event.key);" />
						</div>
						<div class="input-group">
							<label for="phone">Contact No.<span class="mandatory">*</span></label> <input
								type="text" id="phone" name="phone" required
								onkeypress="return /[0-9]/.test(event.key);" />
						</div>
						<div class="input-group">
							<label for="idcard">Identification Card No.</label> <input
								type="text" id="idcard" name="idcard" required
								 />
						</div>
						<div class="input-group">
							<label for="nationality">Nationality<span class="mandatory">*</span></label>
							<input type="text" id="nationality" name="nationality" required
								onkeyup="capLtr(this.value,'nationality');" />
						</div>

						<div class="input-group">
							<label for="officerToMeet">Officer to Meet<span
								class="mandatory">*</span></label> <select id="officerToMeet"
								name="officerToMeet" required>
								<%=officerOptionsHtml.toString()%>
							</select>
						</div>

						<div class="input-group full-width">
							<label for="localAddress">Local Address</label> <input
								type="text" id="localAddress" name="localAddress" 
								onkeyup="capLtr(this.value,'localAddress');" />
						</div>
						
						<div class="input-group full-width">
							<label for="permanentAddress">Permanent Address<span
								class="mandatory">*</span></label> <input type="text"
								id="permanentAddress" name="permanentAddress" required
								onkeyup="capLtr(this.value,'permanentAddress');" />
						</div>

						<!-- Validity Dates -->
						<div class="input-group full-width">
							<label>Validity Period<span class="mandatory">*</span></label>
							<div class="validity-group">
								<div class="input-group" style="margin-bottom: 0;">
									<label for="valdity_fromDate">From:</label> <input type="date"
										id="valdity_fromDate" name="valdity_fromDate"
										value="<%=formattedDate%>" required />
								</div>
								<div class="input-group" style="margin-bottom: 0;">
									<label for="valdity_toDate">To:</label> <input type="date"
										id="valdity_toDate" name="valdity_toDate" required />
								</div>
							</div>
						</div>

						<!-- Submit and Reset -->
						<div class="button-container">
							<input type="submit" value=" Submit Pass" /> <input type="reset"
								value="Clear Form" />
						</div>
					</div>
				</form>
			</div>

			<!-- 📷 Right Camera -->
			<div class="camera-column">
				<div class="video-container">
					<label>Visitor Photo Capture</label>
					<video id="video" width="320" height="240" autoplay></video>
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
					capture is mandatory for submission.
				</p>
			</div>
		</div>
	</div>
</body>
</html>