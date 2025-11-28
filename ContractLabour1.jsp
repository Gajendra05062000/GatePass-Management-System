<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="gatepass.Database" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>




<%
// Database reference
gatepass.Database db = new gatepass.Database();

// --- Initialization Variables ---
Connection conn = null;
Statement st = null;
ResultSet rs = null;
int nextSerNo = 1;

// --- Date/Time Initialization ---
// LocalDate currentDate = LocalDate.now(); // Not used in this version, kept for reference
// String formattedDate = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));


// --- 1. Get Next Serial Number for Display (Pre-POST) ---
try {
    conn = db.getConnection();
    st = conn.createStatement();
    // Use the maximum ID to ensure the user sees the next available number.
    // The Servlet will re-calculate this atomically during the transaction.
    rs = st.executeQuery("SELECT MAX(SER_NO) FROM GATEPASS_CONTRACT_LABOUR");
    if (rs.next()) {
        int maxId = rs.getInt(1);
        nextSerNo = rs.wasNull() ? 1 : maxId + 1;
    } 
} catch (SQLException e) {
    System.err.println("Database error generating Sr. No.: " + e.getMessage());
    // Fallback: nextSerNo remains 1
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (st != null) try { st.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    conn = null; st = null; rs = null; // Reset
}


// --- 2. Dynamic Contract Dropdown Generation (Pre-POST) ---
    StringBuilder contractOptionsHtml = new StringBuilder();
    Connection connContract = null;
    Statement stContract = null;
    ResultSet rsContract = null;
    
    try {
        connContract = db.getConnection();
        String sql = "SELECT ID, CONTRACT_NAME FROM GATEPASS_CONTRACT ORDER BY ID ASC";
        stContract = connContract.createStatement();
        rsContract = stContract.executeQuery(sql);
        
        contractOptionsHtml.append("<option value=\"\" selected disabled>-- Select Contract --</option>");

        while (rsContract.next()) {
            String contractId = rsContract.getString("ID");
            String contractName = rsContract.getString("CONTRACT_NAME");
            
            // Embed the full descriptive string into the option's VALUE
            String contractDisplayValue = "(" + contractId + ") " + contractName;

            contractOptionsHtml.append("<option value=\"").append(contractDisplayValue).append("\">")
            .append(" (").append(contractId).append(") ").append(contractName).append("</option>");
        }
    } catch (SQLException e) {
        contractOptionsHtml.append("<option value=\"\" disabled>⚠️ Error loading contracts</option>");
    } finally {
        if (rsContract != null) try { rsContract.close(); } catch (SQLException ignore) {}
        if (stContract != null) try { stContract.close(); } catch (SQLException ignore) {}
        if (connContract != null) try { connContract.close(); } catch (SQLException ignore) {}
    }

// --- Status/Message Handling (For messages forwarded from the Servlet) ---
    String message = (String) request.getAttribute("message");
    Boolean isError = (Boolean) request.getAttribute("isError");
    String messageClass = (isError != null && isError) ? "error" : "success";
%>

<html>
<head>
<title>Contract Labour / Trainee Gate Pass</title>

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

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
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

input[type="text"], 
input[type="date"], 
select { 
	padding: 10px 12px;
	border: 1px solid var(--input-border);
	border-radius: 6px;
	width: 100%;
	transition: 0.2s;
    background-color: var(--bg-light);
    box-sizing: border-box;
}

input[type="text"]:focus,
input[type="date"]:focus,
select:focus { 
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
.validity-group > div {
    flex: 1;
}

/* --- Renewal Type Styling --- */
.renewal-group {
    display: flex;
    align-items: center;
    gap: 15px;
}
.renewal-group select {
    flex-grow: 0;
    width: 120px;
}
.renewal-group input[type="text"] {
    flex-grow: 1;
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
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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
#video { display: block; } 

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
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
    text-align: center;
    min-width: 300px;
    animation: slideDown 0.3s ease-out;
}

.custom-alert.error {
    background-color: var(--accent-red);
    color: white; 
    border: 1px solid #c82333;
}

.custom-alert.success {
    background-color: #d4edda;
    color: #155724; 
    border: 1px solid #c3e6cb;
}


@keyframes slideDown {
    from { top: -60px; opacity: 0; }
    to { top: 20px; opacity: 1; }
}

/* Responsive adjustments */
@media (max-width: 992px) {
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
    .renewal-group {
        flex-direction: column;
        align-items: flex-start;
    }
}
</style>

 	
<script>
let currentStream;
// Global flag to track if the limit check failed
let limitCheckFailed = false;

function displayCustomAlert(message, type) {
    const alertBox = document.getElementById('customAlertBox');
    
    // Set message and class (error, success, info)
    alertBox.innerHTML = message;
    alertBox.className = 'custom-alert ' + type; 
    
    alertBox.style.display = 'block';

    // Automatically hide after 4 seconds
    setTimeout(() => {
        alertBox.style.display = 'none';
    }, 4000);
}


function extractContractId(displayValue) {
    if (displayValue && displayValue.startsWith("(")) {
        const endIndex = displayValue.indexOf(")");
        if (endIndex > 0) {
            return displayValue.substring(1, endIndex).trim();
        }
    }
    return null;
}

function checkContractLimit(displayValue) {
    const contractId = extractContractId(displayValue);
    limitCheckFailed = false; // Reset the flag

    if (!contractId) {
        return; // Exit if no valid ID is extracted
    }
    
    // Clear any previous alert after 1 second for better UX
    setTimeout(() => {
        document.getElementById('customAlertBox').style.display = 'none';
    }, 1000);
    
    const urlCheck = "CheckLabourLimit.jsp?contractId=" + contractId;

    fetch(urlCheck)
        .then(response => {
            if (!response.ok) throw new Error('Network response was not ok. Status: ' + response.status);
            return response.json(); // Assuming the endpoint returns JSON
        })
        .then(data => {
            if (data.status === 'error') {
                throw new Error(data.message);
            }
            
            const currentCount = parseInt(data.currentCount);
            const labourSize = parseInt(data.labourSize);
            const contractName = data.contractName;

            if (currentCount >= labourSize) {
                // Limit Reached!
                limitCheckFailed = true;
                const msg = `⚠️ **LIMIT REACHED:** Contract **${contractName}** (ID: ${contractId}) has ${currentCount} passes, which meets or exceeds the limit of ${labourSize}. You cannot issue a new pass.`;
                displayCustomAlert(msg, 'error');
                
                // Reset the dropdown to the placeholder to force selection again
                document.getElementById("contractId").value = ""; 
            } else {
                // Limit OK
                const msg = `✅ Contract **${contractName}** (ID: ${contractId}) has ${currentCount} passes. Limit is ${labourSize}. Pass issuance is allowed.`;
                displayCustomAlert(msg, 'success');
            }
        })
        .catch(error => {
            console.error('Error checking contract limit:', error);
            displayCustomAlert("Critical Error checking contract limit status: " + error.message, 'error');
            // If AJAX fails, assume the user must re-select
            document.getElementById("contractId").value = ""; 
            limitCheckFailed = true;
        });
}

// ----------------------------------------------------
// Core Validation Functions (Updated)
// ----------------------------------------------------
function validateForm(form) {
    const imageData = document.getElementById("imageData").value;
  
    // 1. Image Check
    if (!imageData) { 
        const msg = "Please capture a photo before submitting!";
        displayCustomAlert(msg, 'error');
        return false; 
    }
  
    // 2. Contract Selection Check
    const contractSelect = document.getElementById("contractId");
    // Check if the value is the disabled placeholder
    if (contractSelect && contractSelect.value.startsWith("(") === false) { 
        displayCustomAlert("Please select the Contract for this labour.", 'error');
        return false;
    }
    
    // 3. Limit Check Flag
    if (limitCheckFailed) {
        displayCustomAlert("The selected contract is at its labour limit. Please select a valid contract or check the limit.", 'error');
        return false;
    }
  
    // 4. Date Check (chains validation result)
    return ValidateForm2(form); 
}

// --- Original Camera/Utility Functions Below ---
function openCamera() {
  const video = document.getElementById("video");
  const canvas = document.getElementById("canvas");
  const previewImg = document.getElementById("photoPreview");

  canvas.style.display = "none";
  previewImg.style.display = "none";
  video.style.display = "block";
  video.style.border = "3px solid var(--primary-navy)";

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
      console.error("Error accessing camera: " + err.message);
      displayCustomAlert("Camera access denied. Photo capture disabled.", 'error');
    });
}

function capturePhoto() {
  const video = document.getElementById("video");
  const canvas = document.getElementById("canvas");
  const previewImg = document.getElementById("photoPreview");

  if (video.style.display === 'none' || video.paused) {
      displayCustomAlert("Camera stream not active. Click Retake.", 'error');
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
	const element = document.getElementById(id);
    if (element) {
	  element.value = value.toUpperCase();
    }
}

function ValidateForm2(form) {
    const fromDateStr = form.valdity_fromDate.value;
    const toDateStr = form.valdity_toDate.value;
    
    if (!fromDateStr || !toDateStr) { return true; }

    const fromDate = new Date(fromDateStr).getTime();
    const toDate = new Date(toDateStr).getTime();

    if (fromDate > toDate) {
        const msg = "The 'From Date' cannot be later than the 'To Date'.";
        displayCustomAlert(msg, 'error');
        return false;
    }
    
    return true; 
}

function retrieveSerNoDetails() {
  const refNoInput = document.getElementById('refNo');
  const refNo = refNoInput ? refNoInput.value : "";
  
  if (refNo.trim() === "") return;

  const urlRefNoDetails = "LabourGatePassSerNoDetail?refNo=" + refNo;

  fetch(urlRefNoDetails)
    .then(response => {
        if (!response.ok) throw new Error('Network response was not ok.');
        return response.text();
    })
    .then(responseText => {
        var eQtrArr = responseText.split('|');
        var fields = ["name","fatherName","desig","age","localAddress","permanentAddress","contrctrNameAddress","identification","vehicleNumber", "valdity_fromDate", "valdity_toDate"];
        
        for (let i=0; i<fields.length; i++) {
          const value = (eQtrArr[i] && eQtrArr[i] !== "null") ? eQtrArr[i] : "";
          const element = document.getElementById(fields[i]);
          if (element) {
              element.value = value;
              if (fields[i] !== "valdity_fromDate" && fields[i] !== "valdity_toDate") {
                  capLtr(value, fields[i]);
              }
          }
        }
        displayCustomAlert("Details loaded successfully for Ref. No. " + refNo, 'success');
    })
    .catch(error => {
        console.error('Error fetching details:', error);
        displayCustomAlert("Could not find previous record for Ref. No. " + refNo, 'error');
    });
}

function enableRefNo() {
  const selectElement = document.forms["text_form"].renwlTypeSel;
  const refNoInput = document.getElementById("refNo");

  if (selectElement && refNoInput) {
    if (selectElement.value == "Old") {
      refNoInput.disabled = false;
      refNoInput.focus();
    } else {
      refNoInput.disabled = true;
      refNoInput.value = "";
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
    enableRefNo();
    
    // Display message forwarded from the Servlet if present
    const forwardedMessage = "<%= (message != null) ? message : "" %>";
    const forwardedIsError = "<%= (isError != null) ? isError : "false" %>";
    if (forwardedMessage) {
        displayCustomAlert(forwardedMessage, forwardedIsError === "true" ? 'error' : 'success');
    }
});

</script>

</head>

<body onload="openCamera()" onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode}">

<div id="customAlertBox" style="display:none;" class="custom-alert"></div>

<div class="container">
  <h2>CONTRACT LABOUR / TRAINEE GATE PASS</h2>
  
    <div class="main-grid">
      <div>
        <form action="SaveContractLabourData" method="post" 
              name="text_form"
              onsubmit="return validateForm(this)">
              <input type="hidden" id="imageData" name="imageData">
                 <div class="full-width">
                    <p style="font-size: 13px; color: #dc3545; font-weight: 600;">All Fields marked with (<span class="mandatory">*</span> ) are mandatory.</p>
                </div>
              <div class="form-grid">
                
                <div class="input-group">
    <label for="contractId">Contract Name / No.<span class="mandatory">*</span></label>
    <select id="contractId" name="contractId" required onchange="checkContractLimit(this.value)">
        <%= contractOptionsHtml.toString() %>
    </select>
</div>
                <div class="input-group">
                    <label for="worksite">WorkSite<span class="mandatory">*</span></label>
                    <input type="text" name="worksite" id="worksite" value="NFL Panipat" readonly required />
                </div>
                <div class="input-group">
                    <label for="srNo">Contract Labour/Trainee Pass No.<span class="mandatory">*</span></label>
                    <input type="text" name="srNo" id="srNo" value="<%=nextSerNo%>" readonly required />
                </div>
                
                <div class="input-group">
                    <label for="renwlTypeSel">Pass Type / Ref. No.<span class="mandatory">*</span></label>
                    <div class="renewal-group">
                        <select name="renwlTypeSel" onchange="enableRefNo();" required>
                            <option value="New">New</option>
                            <option value="Old">Renewal</option>
                        </select>
                        <input type="text" id="refNo" name="refNo" disabled="true" placeholder="Ref. No. for Renewal" onblur="retrieveSerNoDetails();"/>
                    </div>
                </div>

                <div class="input-group">
                    <label for="name">Name<span class="mandatory">*</span></label>
                    <input type="text" id="name" name="name" 
                            onkeyup="capLtr(this.value,'name');" 
                            onkeypress="return /[A-Za-z\s]/.test(event.key);" 
                            required/>
                </div>

                <div class="input-group">
                    <label for="fatherName">Father Name<span class="mandatory">*</span></label>
                    <input type="text" id="fatherName" name="fatherName" 
                            onkeyup="capLtr(this.value,'fatherName');" 
                            onkeypress="return /[A-Za-z\s]/.test(event.key);" 
                            required/>
                </div>

                <div class="input-group">
                    <label for="desig">Designation</label>
                    <input type="text" id="desig" name="desig" 
                            onkeyup="capLtr(this.value,'desig');" 
                            onkeypress="return /[A-Za-z\s]/.test(event.key);" 
                            required/>
                </div>

                <div class="input-group">
                    <label for="age">Age<span class="mandatory">*</span></label>
                    <input type="text" id="age" name="age" maxlength="2" 
                            onkeypress="return /[0-9]/.test(event.key);" 
                            required/>
                </div>
                <div class="input-group">
                    <label for="Aadhaar">Aadhaar Card No.<span class="mandatory">*</span></label>
                    <input type="text" id="Aadhaar" name="Aadhaar" maxlength="12" 
                            onkeypress="return /[0-9]/.test(event.key);" 
                            required/>
                </div>
                <div class="input-group">
                    <label for="Aadhaar">Mobile No.<span class="mandatory">*</span></label>
                    <input type="text" id="phone" name="phone" maxlength="10" 
                            onkeypress="return /[0-9]/.test(event.key);" 
                            required/>
                </div>
                

                <div class="input-group full-width">
                    <label for="localAddress">Local Address<span class="mandatory">*</span></label>
                    <input type="text" id="localAddress" name="localAddress" 
                            onkeyup="capLtr(this.value,'localAddress');" 
                            required/>
                </div>

                <div class="input-group full-width">
                    <label for="permanentAddress">Permanent Address<span class="mandatory">*</span></label>
                    <input type="text" id="permanentAddress" name="permanentAddress" 
                            onkeyup="capLtr(this.value,'permanentAddress');" 
                            required/>
                </div>

                <div class="input-group full-width">
                    <label for="contrctrNameAddress">Contractor Name / Address</label>
                    <input type="text" id="contrctrNameAddress" name="contrctrNameAddress" 
                            onkeyup="capLtr(this.value,'contrctrNameAddress');" 
                            required/>
                </div>

                <div class="input-group">
                    <label for="vehicleNumber">Vehicle No.</label>
                    <input type="text" id="vehicleNumber" name="vehicleNumber" 
                            onkeyup="capLtr(this.value,'vehicleNumber');" 
                            maxlength="12"/>
                </div>

                <div class="input-group">
                    <label for="identification">Identification Mark</label>
                    <input type="text" id="identification" name="identification" 
                            onkeyup="capLtr(this.value,'identification');" 
                            />
                </div>

                <div class="input-group full-width">
                    <label>Validity Period<span class="mandatory">*</span></label>
                    <div class="validity-group">
                        <div class="input-group" style="margin-bottom: 0;">
                            <label for="valdity_fromDate">From:</label>
                            <input type="date" id="valdity_fromDate" name="valdity_fromDate" required/>
                        </div>
                        <div class="input-group" style="margin-bottom: 0;">
                            <label for="valdity_toDate">To:</label>
                            <input type="date" id="valdity_toDate" name="valdity_toDate" required/>
                        </div>
                    </div>
                </div>
                


                <div class="button-container">
                    <input type="submit" value="Submit"/>
                    <input type="reset" value="Reset"/>
                </div>
              </div>
        </form>
      </div>

      <div class="camera-column">
        <div class="video-container">
          <label>Photo Capture</label>
          <video id="video" width="320" height="240" autoplay></video>
          <canvas id="canvas" width="320" height="240" style="display:none;"></canvas>
          <img id="photoPreview" alt="Captured Photo Preview"/>
          <br>
          <div class="camera-actions">
            <button type="button" onclick="capturePhoto()">&#128247; Capture Photo</button>
            <button type="button" onclick="retakePhoto()">&#8635; Retake Photo</button>
          </div>
        </div>
        <p style="text-align: center; color: #6c757d; margin-top: 10px; font-size: 13px;">Photo capture is mandatory for submission.</p>
      </div>
    </div>
</div>

</body>
</html>