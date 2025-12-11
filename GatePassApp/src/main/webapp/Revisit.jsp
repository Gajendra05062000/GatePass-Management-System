<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.time.*, java.time.format.DateTimeFormatter,java.io.*,java.util.Base64,gatepass.CommonService,gatepass.Database"%>
<%@ page import="java.io.*"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.FileUploadException"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.io.output.*"%>
<%
    // ==========================================================
    // 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache");    // HTTP 1.0.
    response.setDateHeader("Expires", 0);        // Proxies.

    // ==========================================================
    // 🔑 SESSION AUTHENTICATION CHECK
    // ==========================================================
    // Check if the "username" session attribute exists (set during successful login)
    if (session.getAttribute("username") == null) {
        // If not authenticated, redirect to the main login page
        response.sendRedirect("login.jsp");
        return; // Stop processing the rest of the page
    }
%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE html>
<html>
  <head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <title>Visitor Revisit Registration</title>

	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
/* --- Global styles --- */
:root {
	--primary-navy: #1e3c72;
	--accent-blue: #007bff;
	--accent-red: #dc3545;
	--bg-light: #f8f9fa;
	--input-border: #ced4da;
	--shadow-light: 0 4px 12px rgba(0, 0, 0, 0.08);
}

* { box-sizing: border-box; }

body {
	font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
	background: var(--bg-light);
	margin: 0;
	padding: 30px;
}

.top-search {
	position: absolute;
	left: 50%;
	transform: translateX(-50%);
	width: 600px;
	z-index: 31;
	display:flex;
	align-items:center;
	justify-content:center;
	gap:10px;
	background:#f8f9fa;
	border-radius:8px;
	padding:10px;
	box-shadow:0 2px 6px rgba(0,0,0,0.08);
	border:1px solid #e6e9ee;
}

.top-search label { font-size:14px; color:#333; font-weight:250; }
.top-search label b{ font-size:14px; color:green; font-weight:250; }
.top-search input[type="text"] { padding:8px 10px; border:1px solid #ccc; border-radius:6px; width:180px; font-size:14px; }
.top-search input[type="submit"] { padding:8px 14px; border:none; border-radius:6px; background:var(--primary-navy); color:#fff; cursor:pointer; font-size:14px; }

.container {
	background-color: white;
	width: 95%;
	max-width: 1200px;
	margin: 90px auto 30px; /* leave space for top-search */
	padding: 30px 50px;
	border-radius: 12px;
	box-shadow: 0px 6px 30px rgba(0, 0, 0, 0.12);
	animation: fadeIn 0.9s ease;
}

@keyframes fadeIn {
	from { opacity:0; transform: translateY(20px); }
	to { opacity: 1; transform: translateY(0); }
}

h2 {
	text-align: center;
	color: var(--primary-navy);
	margin-bottom: 18px;
	font-weight: 700;
	border-bottom: 2px solid #e9ecef;
	padding-bottom: 10px;
	font-size:22px;
}

/* Layout */
.main-grid {
	display: grid;
	grid-template-columns: 2fr 1fr;
	gap: 36px;
	align-items: start;
}

.form-grid {
	display: grid;
	grid-template-columns: repeat(2, 1fr);
	gap: 14px 22px;
}

.full-width { grid-column: span 2; }

.input-group { display: flex; flex-direction: column; }

label {
	font-weight: 600;
	color: #343a40;
	margin-bottom: 6px;
	font-size: 14px;
}

input[type="text"], input[type="date"], input[type="time"], select {
	padding: 10px 12px;
	border: 1px solid var(--input-border);
	border-radius: 6px;
	width: 100%;
	transition: 0.18s;
	background-color: var(--bg-light);
	box-sizing: border-box;
	appearance: none;
	-webkit-appearance: none;
	-moz-appearance: none;
	font-size:14px;
}

input[type="text"]:focus, input[type="date"]:focus, input[type="time"]:focus, select:focus {
	border-color: var(--accent-blue);
	box-shadow: 0 0 6px rgba(0, 123, 255, 0.12);
	outline: none;
	background-color: white;
}

input[readonly] { background-color: #f1f3f5 !important; color: #6c757d; }

.button-container {
	grid-column: span 2;
	text-align: center;
	padding-top: 14px;
	margin-top: 18px;
	border-top: 1px solid #f1f1f1;
}

button, input[type="submit"], input[type="reset"] {
	background-color: var(--primary-navy);
	border: none;
	color: white;
	padding: 10px 22px;
	font-size: 15px;
	font-weight: 600;
	border-radius: 6px;
	cursor: pointer;
	transition: 0.25s;
	margin: 6px;
	box-shadow: 0 3px 10px rgba(0, 0, 0, 0.06);
}

input[type="submit"] { background-color: var(--accent-blue); }
input[type="submit"]:hover { background-color: #0056b3; }
input[type="reset"] { background-color: var(--accent-red); }
button:hover, input[type="reset"]:hover { background-color: #c82333; transform: translateY(-1px); }

.video-container {
	text-align: center;
	background: var(--bg-light);
	border-radius: 10px;
	padding: 18px;
	box-shadow: var(--shadow-light);
	border: 1px solid #e6e9ee;
}

#video, #canvas, #photoPreview {
	border-radius: 8px;
	border: 3px solid var(--primary-navy);
	width: 100%;
	max-width: 320px;
	height: 240px;
	object-fit: cover;
	display: none;
	margin-bottom: 12px;
}

#video { display: block; }
.camera-actions { display: flex; justify-content: center; gap: 10px; margin-top:6px; }

@media ( max-width : 992px) {
	.main-grid { grid-template-columns: 1fr; }
	.form-grid { grid-template-columns: 1fr; }
	.full-width { grid-column: span 1; }
	.container { padding: 20px; margin-top: 80px; }
	.top-search { width: 90%; left:50%; transform:translateX(-50%); }
}

.mandatory { color: var(--accent-red); margin-left: 4px; font-weight:700; }

.custom-alert {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 9999;
    padding: 14px 22px;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 600;
    min-width: 300px;
    text-align: center;
    color: #fff;
    box-shadow: 0 6px 18px rgba(0,0,0,0.12);
    animation: fadeSlide 0.28s ease-out;
    display: none;
}

.custom-alert.error { background-color: #c0392b; }
.custom-alert.success { background-color: #27ae60; }

@keyframes fadeSlide {
    from { opacity: 0; top: 0px; }
    to { opacity: 1; top: 20px; }
}
 </style>

<script>
/* -------------------------------
   Shared JS: camera, pincode, alerts, uppercase
   ------------------------------- */
let currentStream;
let pincodeData = {};

document.addEventListener("DOMContentLoaded", function() {
    // don't auto-open camera until form is loaded
    // openCamera();  // will be called when form visible
    loadPincodeData();
});

function displayCustomAlert(message, type) {
    const alertBox = document.getElementById("customAlertBox");
    if (!alertBox) return;
    alertBox.innerHTML = message;
    alertBox.className = "custom-alert " + type;
    alertBox.style.display = "block";
    setTimeout(() => { alertBox.style.display = "none"; }, 3500);
}

async function loadPincodeData() {
  try {
    const response = await fetch("pincode_database.json");
    if (!response.ok) throw new Error("HTTP " + response.status);
    pincodeData = await response.json();
    console.log("✅ Pincode data loaded");
  } catch (err) {
    console.warn("Pincode lookup disabled:", err);
    const pincodeInput = document.getElementById("pincode");
    if (pincodeInput) pincodeInput.placeholder = "Pincode auto-lookup disabled.";
  }
}

function fetchOfflinePincodeDetails() {
    const pincodeInput = document.getElementById("pincode");
    if(!pincodeInput) return;
    const pincode = pincodeInput.value.trim();
    const districtField = document.getElementById("district");
    const stateField = document.getElementById("state");

    if(districtField) districtField.value = "";
    if (stateField && stateField.tagName.toLowerCase() === "select") {
        stateField.selectedIndex = 0;
    } else if(stateField) {
        stateField.value = "";
    }

    if (pincode.length !== 6 || isNaN(pincode)) {
        displayCustomAlert("Please enter a valid 6-digit Pincode.", "error");
        return;
    }

    const details = pincodeData[pincode];
    if (details) {
        if(districtField) districtField.value = details.district ? details.district.toUpperCase() : "";
        if (stateField) {
            if (stateField.tagName.toLowerCase() === "select") {
                const opts = stateField.options;
                let found = false;
                for (let i=0;i<opts.length;i++){
                    if (opts[i].value.toLowerCase() === details.state.toLowerCase()){
                        stateField.selectedIndex = i;
                        found = true; break;
                    }
                }
                if (!found) {
                    const o = document.createElement("option");
                    o.value = details.state;
                    o.text = details.state;
                    o.selected = true;
                    stateField.appendChild(o);
                }
            } else {
                stateField.value = details.state ? details.state.toUpperCase() : "";
            }
        }
    } else {
        displayCustomAlert("Pincode not found in local data. Please enter District/State manually.", "error");
    }
}

function openCamera() {
  const video = document.getElementById("video");
  const canvas = document.getElementById("canvas");
  const previewImg = document.getElementById("photoPreview");
  if (!video) return;
  canvas.style.display = "none";
  previewImg.style.display = "none";
  video.style.display = "block";
  video.style.border = "3px solid var(--primary-navy)";

  if (currentStream) {
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
  if (!video || !canvas || !previewImg) return;
  const context = canvas.getContext("2d");

  canvas.width = 320;
  canvas.height = 240;
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
  const imgField = document.getElementById("imageData");
  if(imgField) imgField.value = dataUrl;
  displayCustomAlert("Photo captured successfully.", "success");
}

function retakePhoto() {
  const previewImg = document.getElementById("photoPreview");
  if (previewImg) previewImg.style.display = "none";
  const imgField = document.getElementById("imageData");
  if(imgField) imgField.value = "";
  openCamera();
}

function capLtr(value, id) {
  const element = document.getElementById(id);
  if (element) element.value = value.toUpperCase();
}

function validateForm() {
    const imageData = document.getElementById("imageData").value;
    if (!imageData || imageData.length < 50) {
        displayCustomAlert("Please capture a photo before submitting!", "error");
        return false;
    }
    const officerSelect = document.getElementById("officertomeet");
    if (!officerSelect || officerSelect.value === "" || officerSelect.value === null) {
        displayCustomAlert("Please select an officer.", "error");
        return false;
    }
    const pincodeEl = document.getElementById("pincode");
    if (pincodeEl) {
        const pincode = pincodeEl.value.trim();
        if (pincode.length !== 6 || isNaN(pincode)) {
            displayCustomAlert("Please enter a valid 6-digit Pincode.", "error");
            return false;
        }
    }
    const mobile = document.getElementById("number").value.trim();
    if (mobile.length < 10) {
        displayCustomAlert("Please enter a valid mobile number.", "error");
        return false;
    }
    return true;
}
</script>

<%
/* -------------------------------
   Server-side: Load previous visitor record,
   calculate new ID, and build officer dropdown
   ------------------------------- */
String prevId = request.getParameter("id");
String viewAction = request.getParameter("view"); // when top-search submits ?view=View
// We'll show the form only if prevId is provided and valid; otherwise show search box (and placeholder)
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;
int newId = 1;

// officer dropdown HTML
StringBuilder officerOptionsHtml = new StringBuilder();
officerOptionsHtml.append("<option value=\"\" selected disabled>-- Select Officer --</option>");

try {
    Database db = new Database();
    conn = db.getConnection();

    // compute new id (safe even if prevId null)
    Statement s2 = conn.createStatement();
    ResultSet r2 = s2.executeQuery("SELECT MAX(ID) FROM visitor");
    if (r2.next()) {
        int max = r2.getInt(1);
        newId = (r2.wasNull() ? 1 : max + 1);
    }
    r2.close(); s2.close();

    // load officer list
    Statement stOfficer = conn.createStatement();
    ResultSet rsOfficer = stOfficer.executeQuery("SELECT officers FROM officertomeet ORDER BY officers ASC");
    while (rsOfficer.next()) {
        String officerName = rsOfficer.getString("officers");
        String esc = officerName != null ? officerName.replace("\"", "&quot;") : officerName;
        officerOptionsHtml.append("<option value=\"").append(esc).append("\">").append(esc).append("</option>");
    }
    rsOfficer.close(); stOfficer.close();

    // if prevId provided, fetch record
    if (prevId != null && !prevId.trim().isEmpty()) {
        ps = conn.prepareStatement("SELECT * FROM visitor WHERE ID = ?");
        ps.setString(1, prevId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            // no record found; we'll display message on page
            rs.close(); ps.close();
            rs = null; ps = null;
        } else {
            // rs points to the visitor record; keep it for filling form below
        }
    }

} catch (Exception e) {
    out.println("<p style='color:red; text-align:center; padding:18px; font-weight:600;'>❌ Error preparing page: " + e.getMessage() + "</p>");
    if (rs != null) try { rs.close(); } catch (Exception ignore) {}
    if (ps != null) try { ps.close(); } catch (Exception ignore) {}
    if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    return;
}
%>
  </head>
  <body onload="openCamera()" onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode}">

<!-- Top search box (submits to same page) -->
<form action="Revisit.jsp" method="get" class="top-search" style="">
  <label  for="id">Visitor ID: <b>NFL/CISF/VISITOR/0</b></label>
  <input type="text" id="id" name="id" placeholder="Enter Visitor ID after 0" value="<%= prevId != null ? prevId : "" %>">
  <input type="submit" name="view" value="View">
  <input type="button" value="New Revisit" onclick="window.location='Revisit.jsp';" title="Clear search">
</form>

<div id="customAlertBox" class="custom-alert" style="display:none;"></div>

<div class="container">
    <h2>VISITOR REVISIT REGISTRATION</h2>

<%
    if (prevId == null || prevId.trim().isEmpty()) {
%>
    <p style="text-align:center; color:#6c757d; padding: 18px 0;">Enter a <strong>Visitor ID</strong> above and click <strong>View</strong> to load previous visit details for revisit registration.</p>
<%
    } else {
        // if prevId provided but rs==null -> not found
        if (rs == null) {
%>
    <p style="text-align:center; color:#c0392b; padding: 18px 0; font-weight:700;">❌ No record found for Visitor ID: <%= prevId %></p>
<%
        } else {
%>

    <div class="main-grid">
        <!-- LEFT: Form -->
        <div>
            <form action="visitor.jsp" method="post" name="revisit_form" onsubmit="return validateForm()">
                <input type="hidden" id="imageData" name="imageData">
                <div class="full-width">
                    <p style="font-size:13px;color:#dc3545;font-weight:600;">All Fields marked with (<span class="mandatory">*</span>) are mandatory.</p>
                </div>

                <div class="form-grid">
                    <!-- Gatepass ID and Previous ID -->
                    <div class="input-group">
                        <label for="id_display">Visitor Gatepass No.<span class="mandatory">*</span></label>
                        <input type="text" id="id_display" name="id" value="<%= newId %>" readonly />
                    </div>

                    <div class="input-group">
                        <label for="previousId">Previous Visit ID<span class="mandatory">*</span></label>
                        <input type="text" id="previousId" name="previousId" value="<%= prevId %>" readonly />
                    </div>

                    <!-- Visiting Department -->
                    <div class="input-group">
                        <label for="department">Visiting Department<span class="mandatory">*</span></label>
                        <input type="text" id="department" name="department" value="<%= rs.getString("DEPARTMENT") != null ? rs.getString("DEPARTMENT") : "" %>" onkeyup="capLtr(this.value,'department');" required/>
                    </div>

                    <div class="input-group">
                        <label for="name">Name<span class="mandatory">*</span></label>
                        <input type="text" id="name" name="name" value="<%= rs.getString("NAME") != null ? rs.getString("NAME") : "" %>" onkeyup="capLtr(this.value,'name');" required />
                    </div>

                    <div class="input-group">
                        <label for="fathername">Father Name<span class="mandatory">*</span></label>
                        <input type="text" id="fathername" name="fathername" value="<%= rs.getString("FATHERNAME") != null ? rs.getString("FATHERNAME") : "" %>" onkeyup="capLtr(this.value,'fathername');" required/>
                    </div>

                    <div class="input-group">
                        <label for="age">Age<span class="mandatory">*</span></label>
                        <input type="text" id="age" name="age" value="<%= rs.getString("AGE") != null ? rs.getString("AGE") : "" %>" size="3" required/>
                    </div>

                    <div class="input-group">
                        <label for="aadhar">Aadhar Card No.<span class="mandatory">*</span></label>
                        <input type="text" id="aadhar" name="aadhar" maxlength="12" value="<%= rs.getString("AADHAR") != null ? rs.getString("AADHAR") : "" %>" onkeypress="return /[0-9]/.test(event.key)" required/>
                    </div>

                    <div class="input-group">
                        <label for="nationality">Nationality<span class="mandatory">*</span></label>
                        <input type="text" id="nationality" name="nationality" value="<%= rs.getString("NATIONALITY") != null ? rs.getString("NATIONALITY") : "INDIAN" %>" onkeyup="capLtr(this.value,'nationality');" readonly/>
                    </div>

                    <div class="input-group full-width">
                        <label for="address">Address<span class="mandatory">*</span></label>
                        <input type="text" id="address" name="address" value="<%= rs.getString("ADDRESS") != null ? rs.getString("ADDRESS") : "" %>" onkeyup="capLtr(this.value,'address');" required/>
                    </div>

                    <div class="input-group">
                        <label for="pincode">Pincode<span class="mandatory">*</span></label>
                        <input type="text" id="pincode" name="pincode" maxlength="6" value="<%= rs.getString("PINCODE") != null ? rs.getString("PINCODE") : "" %>" onchange="fetchOfflinePincodeDetails();" required/>
                    </div>

                    <div class="input-group">
                        <label for="district">District<span class="mandatory">*</span></label>
                        <input type="text" id="district" name="district" value="<%= rs.getString("DISTRICT") != null ? rs.getString("DISTRICT") : "" %>" onkeyup="capLtr(this.value,'district');" required />
                    </div>

                    <div class="input-group">
                        <label for="state">State<span class="mandatory">*</span></label>
                        <select name="state" id="state" required>
                            <option value="" disabled>-- Select State --</option>
                            <% 
                                String[] states = {
                                    "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh",
                                    "Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand",
                                    "Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur",
                                    "Meghalaya","Mizoram","Nagaland","Odisha","Punjab","Rajasthan",
                                    "Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh",
                                    "Uttarakhand","West Bengal",
                                    "Andaman and Nicobar Islands","Chandigarh",
                                    "Dadra and Nagar Haveli and Daman and Diu","Delhi",
                                    "Jammu and Kashmir","Ladakh","Lakshadweep","Puducherry"
                                };
                                String existingState = rs.getString("STATE") != null ? rs.getString("STATE") : "";
                                for (String s : states) {
                                    if (s.equalsIgnoreCase(existingState)) {
                            %>
                                <option value="<%= s %>" selected><%= s %></option>
                            <%      } else { %>
                                <option value="<%= s %>"><%= s %></option>
                            <%      }
                                }
                            %>
                        </select>
                    </div>

                    <div class="input-group">
                        <label for="number">Mobile/Telephone No.<span class="mandatory">*</span></label>
                        <input type="text" id="number" name="number" maxlength="10" value="<%= rs.getString("PHONE") != null ? rs.getString("PHONE") : "" %>" required/>
                    </div>

                    <div class="input-group">
                        <label for="officertomeet">Officer to Meet<span class="mandatory">*</span></label>
                        <select id="officertomeet" name="officertomeet" required>
                            <%= officerOptionsHtml.toString() %>
                        </select>
                    </div>

                    <div class="input-group">
                        <label for="material">Material/Item Carried</label>
                        <input type="text" id="material" name="material" value="<%= rs.getString("MATERIAL") != null ? rs.getString("MATERIAL") : "NIL" %>" onkeyup="capLtr(this.value,'material');" />
                    </div>

                    <div class="input-group">
                        <label for="vehicle">Vehicle Number (if any)</label>
                        <input type="text" id="vehicle" name="vehicle" value="<%= rs.getString("VEHICLE") != null ? rs.getString("VEHICLE") : "" %>" onkeyup="capLtr(this.value,'vehicle');" />
                    </div>

                    <div class="input-group">
                        <label for="purpose">Purpose of Visit<span class="mandatory">*</span></label>
                        <input type="text" id="purpose" name="purpose" value="<%= rs.getString("PURPOSE") != null ? rs.getString("PURPOSE") : "" %>" onkeyup="capLtr(this.value,'purpose');" required />
                    </div>

                    <div class="input-group">
                        <label for="date">Entry Date<span class="mandatory">*</span></label>
                        <input type="date" id="date" name="date" value="<%= java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd")) %>" readonly />
                    </div>

                    <div class="input-group">
                        <label for="time">Entry Time<span class="mandatory">*</span></label>
                        <input type="time" id="time" name="time" value="<%= java.time.LocalTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")) %>" readonly />
                    </div>

                    <div class="button-container">
                        <input type="submit" value=" Generate Revisit Gatepass" />
                        <input type="reset" value="Clear Form" onclick="retakePhoto();"/>
                    </div>
                </div>
            </form>
        </div>

        <!-- RIGHT: Camera -->
        <div class="camera-column">
            <div class="video-container">
                <label style="font-weight:700; display:block; margin-bottom:8px;">Visitor Photo Capture</label>
                <video id="video" width="320" height="240" autoplay style="display:none;"></video>
                <canvas id="canvas" width="320" height="240" style="display:none;"></canvas>
                <img id="photoPreview" alt="Captured Photo Preview" style="max-width:320px; border-radius:6px; display:none;" />
                <div class="camera-actions">
                    <button type="button" onclick="capturePhoto()">📸 Capture</button>
                    <button type="button" onclick="retakePhoto()">↺ Retake</button>
                </div>
            </div>
            <p style="text-align:center; color:#6c757d; margin-top:12px; font-size:13px;">Photo capture is mandatory for submission.</p>
        </div>
    </div>

<%
        } // end rs != null
    } // end prevId provided
%>

</div>

<%
/* close rs/ps/conn opened earlier for fetching record. */
try { if (rs != null) rs.close(); } catch (Exception ignore) {}
try { if (ps != null) ps.close(); } catch (Exception ignore) {}
try { if (conn != null) conn.close(); } catch (Exception ignore) {}
%>

</body>
</html>
