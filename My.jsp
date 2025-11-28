<%@ page language="java" import="java.sql.*,java.time.*,java.time.format.DateTimeFormatter,java.io.*,java.util.Base64,gatepass.Database"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="org.apache.commons.io.output.*"%>
<%@ page import="javaQuery.j2ee.GeoLocation"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
<title>Visitor Revisit Entry</title>

<!-- 📸 CAMERA SCRIPT -->
<script>
let currentStream;
function openCamera() {
  const video = document.getElementById("video");
  const canvas = document.getElementById("canvas");
  const previewImg = document.getElementById("photoPreview");
  canvas.style.display = "none"; 
  previewImg.style.display = "none"; 
  video.style.display = "block"; 
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    alert("Camera not supported in this browser.");
    return;
  }
  navigator.mediaDevices.getUserMedia({ video: true })
    .then(stream => { currentStream = stream; video.srcObject = stream; })
    .catch(err => { alert("Error accessing camera: " + err.message); });
}

function capturePhoto() {
  const video = document.getElementById("video");
  const canvas = document.getElementById("canvas");
  const previewImg = document.getElementById("photoPreview");
  const context = canvas.getContext("2d");
  context.drawImage(video, 0, 0, canvas.width, canvas.height);
  if (currentStream) currentStream.getTracks().forEach(track => track.stop());
  const dataUrl = canvas.toDataURL("image/png");
  previewImg.src = dataUrl;
  previewImg.style.display = "block";
  video.style.display = "none";
  canvas.style.display = "none";
  document.getElementById("imageData").value = dataUrl;
}

function retakePhoto() {
  document.getElementById("photoPreview").style.display = "none";
  openCamera();
}

function validateForm() {
  if (!document.getElementById("imageData").value) {
    alert("Please capture a photo before submitting!");
    return false;
  }
  return true;
}
</script>

<!-- 🌈 Modern CSS -->
<style>
body {
	font-family: "Segoe UI", Arial, sans-serif;
	background: linear-gradient(135deg, #dfe9f3, #ffffff);
	margin: 0;
	padding: 30px;
}
.container {
	background-color: white;
	width: 1100px;
	margin: auto;
	padding: 25px 40px;
	border-radius: 15px;
	box-shadow: 0px 5px 25px rgba(0, 0, 0, 0.2);
	animation: fadeIn 1s ease;
}
@keyframes fadeIn {
	from {opacity: 0; transform: translateY(20px);}
	to {opacity: 1; transform: translateY(0);}
}
h2 {
	text-align: center;
	color: #003366;
	margin-bottom: 20px;
}
table {
	width: 100%;
}
input[type="text"], input[type="date"], input[type="time"] {
	padding: 6px;
	border: 1px solid #ccc;
	border-radius: 5px;
	width: 90%;
	transition: 0.2s;
}
input[type="text"]:focus, input[type="date"]:focus, input[type="time"]:focus {
	border-color: #0078d4;
	box-shadow: 0 0 4px rgba(0, 120, 212, 0.3);
	outline: none;
}
button, input[type="submit"], input[type="reset"] {
	background-color: #0078d4;
	border: none;
	color: white;
	padding: 8px 18px;
	font-size: 14px;
	border-radius: 6px;
	cursor: pointer;
	transition: 0.3s;
	margin: 5px;
}
button:hover, input[type="submit"]:hover, input[type="reset"]:hover {
	background-color: #005fa3;
	transform: translateY(-2px);
}
.video-container {
	text-align: center;
	background: #f8faff;
	border-radius: 10px;
	padding: 15px;
	box-shadow: 0px 3px 10px rgba(0, 0, 0, 0.1);
}
#video, #canvas, #photoPreview {
	border-radius: 8px;
	border: 1px solid #ccc;
}
#photoPreview {
	width: 320px;
	height: 240px;
	object-fit: cover;
	display: none;
}
td {
	vertical-align: top;
	padding: 5px;
}
td:first-child {
	font-weight: bold;
	color: #333;
}
</style>
</head>

<body onload="openCamera()">

<%
    String prevId = request.getParameter("id");
    Database db = new Database();
    Connection conn = db.getConnection();

    // Fetch previous visitor record
    Statement st = conn.createStatement();
    ResultSet rs = st.executeQuery("SELECT * FROM visitor WHERE ID='" + prevId + "'");
    if (!rs.next()) {
        out.println("<p style='color:red;text-align:center;'>❌ No record found for Visitor ID: " + prevId + "</p>");
        return;
    }

    // Generate new pass ID
    Statement st2 = conn.createStatement();
    ResultSet rs2 = st2.executeQuery("SELECT MAX(ID) FROM visitor");
    int newId = 1;
    if (rs2.next()) newId = rs2.getInt(1) + 1;
    rs2.close(); st2.close();

    // Current Date + Time
    LocalDate currentDate = LocalDate.now();
    LocalTime currentTime = LocalTime.now();
    String formattedDate = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    String formattedTime = currentTime.format(DateTimeFormatter.ofPattern("HH:mm"));
%>

<div class="container">
	<h2>VISITOR REVISIT REGISTRATION</h2>
	<form action="visitor.jsp" method="post" onsubmit="return validateForm()">
	<input type="hidden" id="imageData" name="imageData">

	<table>
		<tr>
			<td width="60%">
				<table cellpadding="6">
					<tr><td>New Visitor Pass No</td><td><input type="text" name="id" value="<%=newId%>" readonly></td></tr>
					<tr><td>Previous Visit ID</td><td><input type="text" name="previousId" value="<%=prevId%>" readonly></td></tr>

					<tr><td>Name</td><td><input type="text" name="name" value="<%=rs.getString("NAME")%>"></td></tr>
					<tr><td>Father Name</td><td><input type="text" name="fathername" value="<%=rs.getString("FATHERNAME")%>"></td></tr>
					<tr><td>Material</td><td><input type="text" name="material" value="<%=rs.getString("MATERIAL")%>"></td></tr>
					<tr><td>Age</td><td><input type="text" name="age" value="<%=rs.getString("AGE")%>"></td></tr>
					<tr><td>Address</td><td><input type="text" name="address" value="<%=rs.getString("ADDRESS")%>"></td></tr>
					<tr><td>State</td><td><input type="text" name="state" value="<%=rs.getString("STATE")%>"></td></tr>
					<tr><td>District</td><td><input type="text" name="district" value="<%=rs.getString("DISTRICT")%>"></td></tr>
					<tr><td>Pincode</td><td><input type="text" name="pincode" value="<%=rs.getString("PINCODE")%>"></td></tr>
					<tr><td>Nationality</td><td><input type="text" name="nationality" value="<%=rs.getString("NATIONALITY") != null ? rs.getString("NATIONALITY") : "INDIAN"%>"></td></tr>
					<tr><td>Telephone</td><td><input type="text" name="number" value="<%=rs.getString("PHONE")%>"></td></tr>
					<tr><td>Vehicle Number</td><td><input type="text" name="vehicle" value="<%=rs.getString("VEHICLE")%>"></td></tr>
					<tr><td>Date</td><td><input type="date" name="date" value="<%=formattedDate%>" readonly></td></tr>
					<tr><td>Time</td><td><input type="time" name="time" value="<%=formattedTime%>" readonly></td></tr>
					<tr><td>Officer to Meet</td><td><input type="text" name="officertomeet" value="<%=rs.getString("OFFICERTOMEET")%>"></td></tr>
					<tr><td>Purpose</td><td><input type="text" name="purpose" value="<%=rs.getString("PURPOSE")%>"></td></tr>
					<tr>
						<td colspan="2" align="center">
							<input type="submit" value="Generate Revisit Pass">
							<input type="reset" value="Reset">
						</td>
					</tr>
				</table>
			</td>

			<!-- 📷 Live Camera -->
			<td width="40%">
				<div class="video-container">
					<h3>Live Camera</h3>
					<video id="video" width="320" height="240" autoplay></video>
					<canvas id="canvas" width="320" height="240" style="display:none;"></canvas>
					<img id="photoPreview" alt="Captured Photo Preview">
					<br><br>
					<button type="button" onclick="capturePhoto()">Capture Photo</button>
					<button type="button" onclick="retakePhoto()">Retake Photo</button>
				</div>
			</td>
		</tr>
	</table>
	</form>
</div>

<%
	rs.close();
	conn.close();
%>

</body>
</html>
