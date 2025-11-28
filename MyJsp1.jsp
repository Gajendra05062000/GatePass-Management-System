<%@ page language="java" import="java.sql.*" %>
<%@ page import="gatepass.Database.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<html>
<head>
<title>Gate Pass Entry Details</title>

<style>
body {
    background-color: #f0f4f8;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
}

#gatepass {
    background-color: #ffffff;
    max-width:  1100px;
    margin: 50px auto;
    padding: 30px 40px;
    border-radius: 12px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}

h3 {
    text-align: center;
    color: #333;
    margin-bottom: 30px;
}

.form-group {
    margin-bottom: 20px;
}

label {
    display: block;
    margin-bottom: 6px;
    font-weight: 600;
    color: #555;
}

input[type="text"], textarea, select {
    width: 100%;
    padding: 10px;
    font-size: 15px;
    border: 1px solid #ccc;
    border-radius: 6px;
    box-sizing: border-box;
    transition: border 0.3s, box-shadow 0.3s;
}

input[type="text"]:focus, textarea:focus, select:focus {
    border-color: #007BFF;
    box-shadow: 0 0 5px rgba(0,123,255,0.3);
    outline: none;
}

textarea {
    resize: vertical;
}

button {
    padding: 10px 25px;
    font-size: 15px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    transition: background 0.3s, transform 0.2s;
}

button[type="submit"] {
    background-color: #007BFF;
    color: white;
    margin-right: 10px;
}

button[type="submit"]:hover {
    background-color: #0056b3;
    transform: scale(1.05);
}

button[type="reset"] {
    background-color: #6c757d;
    color: white;
}

button[type="reset"]:hover {
    background-color: #5a6268;
    transform: scale(1.05);
}
</style>

<script type="text/javascript">
function Blank_TextField_Validator() {
    var form = document.forms["text_form"];
    if (form.text_name.value == "") { alert("Please fill the NAME"); form.text_name.focus(); return false; }
    if (form.line1.value == "") { alert("Please fill the address"); form.line1.focus(); return false; }
    if (form.vehicle.value == "") { alert("Please fill the vehicle number"); form.vehicle.focus(); return false; }
    if (form.district.value == "") { alert("Please fill the district"); form.district.focus(); return false; }
    if (form.state.value == "") { alert("Please fill the state"); form.state.focus(); return false; }
    if (form.material.value == "") { alert("Please fill the material"); form.material.focus(); return false; }
    if (form.purpose.value == "") { alert("Please fill the purpose"); form.purpose.focus(); return false; }
    return true;
}

function executeCommandss() {
    try {
        WshShell = new ActiveXObject("Wscript.Shell");
        WshShell.run("C://Program Files/VideoCap/iBall Face2Face C8.0 Webcam/VideoCap.exe");
    } catch(err) {
        alert("Error in Opening Web Cam --> " + err);
    }
}
</script>

<%
gatepass.Database db = new gatepass.Database();
String path = db.camInstallationPath();
try { Runtime.getRuntime().exec(path); } 
catch(Exception e1) { e1.printStackTrace(); }

String ip = db.getServerIp();
%>

</head>
<body onload="executeCommandss();">

<div id="gatepass">

    <h3>Gate Pass Details</h3>

    <form action="http://<%=ip %>/visitor/uploadfile" method="post" name="text_form" enctype="multipart/form-data" onsubmit="return Blank_TextField_Validator()">

        <div class="form-group">
            <label>Name</label>
            <input type="text" name="text_name">
        </div>

        <div class="form-group">
            <label>Address</label>
            <textarea name="line1" rows="3"></textarea>
        </div>

        <div class="form-group">
            <label>District</label>
            <input type="text" name="district">
        </div>

        <div class="form-group">
            <label>State</label>
            <select name="state">
                <option value="">Select State</option>
                <option value="Andhra Pradesh">Andhra Pradesh</option>
                <option value="Arunachal Pradesh">Arunachal Pradesh</option>
                <option value="Assam">Assam</option>
                <option value="Bihar">Bihar</option>
                <option value="Chhatisgarh">Chhatisgarh</option>
                <option value="Goa">Goa</option>
                <option value="Gujarat">Gujarat</option>
                <option value="Haryana">Haryana</option>
                <option value="Himachal Pradesh">Himachal Pradesh</option>
                <option value="Jammu & Kashmir">Jammu & Kashmir</option>
                <option value="Jharkhand">Jharkhand</option>
                <option value="Karnataka">Karnataka</option>
                <option value="Kerala">Kerala</option>
                <option value="Madhya Pradesh">Madhya Pradesh</option>
                <option value="Maharashtra">Maharashtra</option>
                <option value="Manipur">Manipur</option>
                <option value="Meghalaya">Meghalaya</option>
                <option value="Mizoram">Mizoram</option>
                <option value="Nagaland">Nagaland</option>
                <option value="Orissa">Orissa</option>
                <option value="Punjab">Punjab</option>
                <option value="Rajasthan">Rajasthan</option>
                <option value="Sikkim">Sikkim</option>
                <option value="Tamil Nadu">Tamil Nadu</option>
                <option value="Tripura">Tripura</option>
                <option value="Uttar Pradesh">Uttar Pradesh</option>
                <option value="Uttaranchal">Uttaranchal</option>
                <option value="West Bengal">West Bengal</option>
            </select>
        </div>

        <div class="form-group">
            <label>Pin Code</label>
            <input type="text" name="pincode">
        </div>

        <div class="form-group">
            <label>Material</label>
            <textarea name="material" rows="3"></textarea>
        </div>

        <div class="form-group">
            <label>Vehicle Number</label>
            <input type="text" name="vehicle">
        </div>

        <div class="form-group">
            <label>Officer to Meet</label>
            <select name="officertomeet">
                <%
                Connection conn = db.getConnection();
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("select officers from officertomeet");
                while(rs.next()) {
                %>
                    <option value="<%=rs.getString(1)%>"><%=rs.getString(1)%></option>
                <% } rs.close(); conn.close(); %>
            </select>
        </div>

        <div class="form-group">
            <label>Purpose</label>
            <input type="text" name="purpose">
        </div>

        <div class="form-group">
            <label>Telephone Number</label>
            <input type="text" name="number">
        </div>

        <div style="text-align:center; margin-top:20px;">
            <button type="submit">Submit</button>
            <button type="reset">Reset</button>
        </div>

    </form>
</div>

</body>
</html>
