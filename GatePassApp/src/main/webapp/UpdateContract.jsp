<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="gatepass.Database" %>

<%
    /* SECURITY HEADERS */
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    /* SESSION CHECK */
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String id = request.getParameter("id");
    
    // --- Flags to control display ---
    boolean showUpdateForm = false;
    String fetchErrorMessage = null; 

    // --- Variables to hold fetched data (initialized only if an ID is present) ---
    String name = "", type = "", reg = "", dept = "", worksite = "", desp = "";
    String contractorName = "", contractorAddress = "", phone = "", adhar = "";
    String validityFrom = "", validityTo = "";
    int labourSize = 0;
    boolean documentExists = false;

    if (id != null && !id.trim().isEmpty()) {
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = new Database().getConnection();
            String sql = "SELECT ID, CONTRACT_NAME, CONTRACT_TYPE, REGISTRATION, DEPARTMENT, WORKSITE, DESCRIPTION, "
                       + "CONTRACTOR_NAME, CONTRACTOR_ADDRESS, PHONE, CONTRACTOR_ADHAR, "
                       + "TO_CHAR(VALIDITY_FROM, 'YYYY-MM-DD') AS VF, "
                       + "TO_CHAR(VALIDITY_TO, 'YYYY-MM-DD') AS VT, "
                       + "LABOUR_SIZE, DOCUMENT1 "
                       + "FROM GATEPASS_CONTRACT WHERE ID = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                // Data found, populate variables
                name = rs.getString("CONTRACT_NAME");
                type = rs.getString("CONTRACT_TYPE");
                reg = rs.getString("REGISTRATION");
                dept = rs.getString("DEPARTMENT");
                worksite = rs.getString("WORKSITE");
                desp = rs.getString("DESCRIPTION");
                contractorName = rs.getString("CONTRACTOR_NAME");
                contractorAddress = rs.getString("CONTRACTOR_ADDRESS");
                phone = rs.getString("PHONE");
                adhar = rs.getString("CONTRACTOR_ADHAR");
                validityFrom = rs.getString("VF");
                validityTo = rs.getString("VT");
                labourSize = rs.getInt("LABOUR_SIZE");
                
                Blob docBlob = rs.getBlob("DOCUMENT1");
                if (docBlob != null && docBlob.length() > 0) {
                    documentExists = true;
                }
                showUpdateForm = true; // Set flag to display the main form
            } else {
                fetchErrorMessage = "Contract ID **" + id + "** not found in the database.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            fetchErrorMessage = "Database Error: " + e.getMessage();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Contract Update</title>
<meta charset="UTF-8">

<style>
/* =============== THEME (Identical to registration.jsp) =============== */
:root {
    --primary-navy: #1e3c72;
    --accent-blue: #007bff;
    --accent-red: #dc3545;
    --bg-light: #f8f9fa;
    --input-border: #ced4da;
    --shadow-light: 0 4px 12px rgba(0,0,0,0.08);
}

body {
    font-family: "Segoe UI", Tahoma, sans-serif;
    background: var(--bg-light);
    margin: 0;
    padding: 30px;
}

.container {
    background: #fff;
    width: 95%;
    max-width: 1200px;
    margin: 20px auto 0 auto;
    padding: 30px 40px;
    border-radius: 15px;
    box-shadow: 0 6px 25px rgba(0,0,0,0.14);
}

h2 {
    text-align: center;
    color: var(--primary-navy);
    font-weight: 700;
    margin-bottom: 25px;
    padding-bottom: 8px;
    border-bottom: 2px solid #e9ecef;
}

/* --- Search Box Styling (New) --- */
.search-container {
    max-width: 600px;
    margin: 0 auto 30px auto;
    background: #fff;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    display: flex;
    gap: 15px;
    align-items: center;
    border: 1px solid #e9ecef;
}
.search-container label {
    font-weight: 600;
    color: var(--primary-navy);
    white-space: nowrap;
}
.search-container input[type="text"] {
    flex-grow: 1;
    padding: 10px 12px;
    border-radius: 6px;
    border: 1px solid var(--input-border);
    box-sizing: border-box;
}
.search-container input[type="submit"] {
    background: #28a745;
    padding: 10px 20px;
    border-radius: 6px;
    color: white;
    border: none;
    cursor: pointer;
    font-weight: 600;
    transition: 0.25s;
}
.search-container input[type="submit"]:hover {
    background: #1e7e34;
}
.message-box {
    max-width: 600px;
    margin: 15px auto;
    padding: 15px;
    border-radius: 8px;
    font-weight: 600;
    text-align: center;
}
.message-box.error {
    background: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}
.message-box.info {
    background: #d1ecf1;
    color: #0c5460;
    border: 1px solid #bee5eb;
}

/* =============== GRID LAYOUT =============== */
.main-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 35px;
}

/* =============== FORM GRID =============== */
.form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 18px 25px;
}
.full-width { grid-column: span 2; }

/* =============== INPUT STYLING (Same as original) =============== */
label {
    font-weight: 600;
    margin-bottom: 4px;
    color: #333;
    display: block;
}
.mandatory { color: var(--accent-red); margin-left: 4px; }

input[type="text"], input[type="date"], select {
    padding: 10px 12px;
    border-radius: 6px;
    border: 1px solid var(--input-border);
    width: 100%;
    background: #fff;
    box-sizing: border-box;
}
input[readonly] {
    background: #e9ecef;
    color: #444;
}

/* =============== BUTTONS (Same as original) =============== */
input[type="submit"] { background: #ffc107; color: #333; }
input[type="submit"]:hover { background: #e0a800; }

input[type="reset"] { background: var(--accent-red); color: #fff; }
input[type="reset"]:hover { background: #b21f2d; }

.button-container {
    grid-column: span 2;
    text-align: center;
    padding-top: 15px;
    border-top: 1px solid #eee;
}

/* =============== DOCUMENT UPLOAD RIGHT PANEL (Same as original) =============== */
.upload-panel {
    background: var(--bg-light);
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-light);
    border: 1px solid #dcdcdc;
}

.upload-panel h3 {
    color: var(--primary-navy);
    text-align: center;
    margin-bottom: 10px;
}

.upload-box {
    border: 1px solid #d4e8f7;
    background: #f0f5ff;
    padding: 14px;
    border-radius: 8px;
}

.file-preview-area {
    margin-top: 10px;
    padding: 12px;
    border-radius: 8px;
    background: #fff;
    border: 1px solid #ddd;
    min-height: 90px;
    display:flex;
    flex-direction:column;
    align-items:center;
    justify-content:center;
}

.preview-thumbnail {
    max-width: 90px;
    border: 1px solid #ccc;
    border-radius: 4px;
    margin-bottom: 6px;
}

.file-name {
    font-weight: 600;
    color: var(--primary-navy);
    font-size: 14px;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.document-status {
    color: #28a745;
    font-weight: 600;
    margin-top: 8px;
}
.remove-doc-btn {
    background: var(--accent-red);
    color: white;
    padding: 5px 10px;
    border-radius: 4px;
    margin-top: 5px;
    font-size: 12px;
}

/* Alerts */
.custom-alert {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    padding: 12px 20px;
    font-weight: 700;
    display:none;
    border-radius: 8px;
    color: #fff;
    z-index: 2000;
}
.custom-alert.success { background: #28a745; }
.custom-alert.error { background: var(--accent-red); }
.custom-alert.info { background: var(--accent-blue); }

/* Responsive */
@media (max-width: 900px) {
    .main-grid { grid-template-columns: 1fr; }
}
</style>

<script>
function capLtr(val,id){ document.getElementById(id).value = val.toUpperCase(); }

function displayCustomAlert(msg,type){
    const box=document.getElementById("customAlertBox");
    box.innerText=msg;
    box.className="custom-alert "+type;
    box.style.display="block";
    setTimeout(()=> box.style.display="none",3500);
}

/* FORM VALIDATION */
function ValidateForm2(form){
    let f=form.valdity_fromDate.value;
    let t=form.valdity_toDate.value;
    if(!f||!t){ displayCustomAlert("Select both validity dates","error"); return false; }
    if(new Date(f)>new Date(t)){
        displayCustomAlert("'From' cannot be later than 'To'","error");
        return false;
    }
    // Set flag for document update
    if(tempSelectedFile){
        document.getElementById("docAction").value = "REPLACE";
    }
    return true;
}
function validateForm(f){ return ValidateForm2(f); }

/* DOCUMENT UPLOAD PREVIEW */
let tempSelectedFile=null;
let existingDocStatus = <%= documentExists %>;

function handleDocumentAdd(){
    const fileInput=document.getElementById("DocumentFile");
    const file=fileInput.files[0];
    if(!file){ displayCustomAlert("Select a file","error"); return; }
    if(file.size > 5*1024*1024){ displayCustomAlert("Max size 5MB","error"); fileInput.value=""; return; }

    tempSelectedFile=file;
    previewDocument(file);
    document.getElementById("docAction").value = "REPLACE"; 
    displayCustomAlert("New Document ready to be uploaded","info");
}

function removeDocument(){
    document.getElementById("DocumentFile").value = "";
    document.getElementById("docAction").value = "REMOVE"; 
    tempSelectedFile=null;
    document.getElementById("documentPreview").innerHTML=`<p style='color: ${document.documentElement.style.getPropertyValue('--accent-red')}'>Document will be deleted on save.</p>`;
    displayCustomAlert("Document marked for deletion","error");
}

function previewDocument(file){
    const area=document.getElementById("documentPreview");
    const name=file.name;
    const type=file.type;
    if(type.startsWith("image/")){
        const r=new FileReader();
        r.onload=function(e){
            area.innerHTML=`<img class="preview-thumbnail" src="${e.target.result}" alt="Preview">
                            <div class="file-name">${name}</div>`;
        }
        r.readAsDataURL(file);
    } else if (type.includes("pdf")){
        area.innerHTML=`<div style="font-size:30px;">📄</div>
                        <div class="file-name">${name}</div>`;
    } else {
        area.innerHTML=`<div style="font-size:30px;">📎</div>
                        <div class="file-name">${name}</div>`;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    // Only run this initial display logic if the form is actually visible (i.e., data was fetched)
    if (<%= showUpdateForm %>) {
        if(existingDocStatus){
            document.getElementById("documentPreview").innerHTML = 
                `<div style="font-size:30px; color: green;">✅</div>
                 <div class="document-status">Current Document Exists.</div>
                 <button type="button" class="remove-doc-btn" onclick="removeDocument()">Remove Current</button>`;
        } else {
            document.getElementById("documentPreview").innerHTML = `<p>No current document saved.</p>`;
        }
        document.getElementById("docAction").value = "KEEP";
    }
});
</script>

</head>

<body>

<div id="customAlertBox" class="custom-alert"></div>

<div class="search-container">
    <form method="get" action="UpdateContract.jsp" style="display:flex; gap:15px; width:100%;">
        <label for="searchId">Enter Contract ID to Update:</label>
        <input type="text" id="searchId" name="id" value="<%= (id != null ? id : "") %>" 
               placeholder="e.g., 123" required style="flex-grow:1;">
        <input type="submit" value="Fetch Details">
    </form>
</div>

<% if (fetchErrorMessage != null) { %>
    <div class="message-box error">
        <%= fetchErrorMessage %>
    </div>
<% } %>


<% if (showUpdateForm) { %>
    <div class="container">
        <h2>Update Contract Details (ID: <%=id%>)</h2>

        <div class="main-grid">

            <div>
                <form action="UpdateContract" method="post" enctype="multipart/form-data" onsubmit="return validateForm(this)">
                    <input type="hidden" name="id" value="<%=id%>"/>
                    <input type="hidden" name="docAction" id="docAction" value="KEEP"/> 
                    
                    <div class="form-grid">

                        <div class="input-group">
                            <label>WorkSite <span class="mandatory">*</span></label>
                            <input type="text" name="worksite" value="<%=worksite%>" readonly/>
                        </div>

                        <div class="input-group">
                            <label>Contract No. <span class="mandatory">*</span></label>
                            <input type="text" name="display_id" value="<%=id%>" readonly/>
                        </div>

                        <div class="input-group">
                            <label>Contract Name <span class="mandatory">*</span></label>
                            <input type="text" id="name" name="name" value="<%=name%>" onkeyup="capLtr(this.value,'name')" required/>
                        </div>

                        <div class="input-group">
                            <label>Contract Type <span class="mandatory">*</span></label>
                            <input type="text" id="type" name="type" value="<%=type%>" onkeyup="capLtr(this.value,'type')" required/>
                        </div>

                        <div class="input-group">
                            <label>Registration No.</label>
                            <input type="text" id="reg" name="reg" value="<%=reg%>" onkeyup="capLtr(this.value,'reg')"/>
                        </div>
                        <div class="input-group">
                            <label>Contract Department</label>
                            <input type="text" id="dept" name="dept" value="<%=dept%>" onkeyup="capLtr(this.value,'dept')"/>
                        </div>
                        <div class="input-group">
                            <label>Validity From <span class="mandatory">*</span></label>
                            <input type="date" id="valdity_fromDate" name="valdity_fromDate" value="<%=validityFrom%>" required/>
                        </div>

                        <div class="input-group">
                            <label>Validity To <span class="mandatory">*</span></label>
                            <input type="date" id="valdity_toDate" name="valdity_toDate" value="<%=validityTo%>" required/>
                        </div>
                        <div class="input-group">
                            <label>Labour Size <span class="mandatory">*</span></label>
                            <input type="text" id="laboursize" name="laboursize" value="<%=labourSize%>" onkeypress="return /[0-9]/.test(event.key)" required/>
                        </div>
                        
                        <div class="input-group">
                            <label>Contractor Name <span class="mandatory">*</span></label>
                            <input type="text" id="ContractorName" name="Contractor" value="<%=contractorName%>" onkeyup="capLtr(this.value,'ContractorName')" required/>
                        </div>
                    
                        <div class="input-group">
                            <label>Contractor Mobile No. <span class="mandatory">*</span></label>
                            <input type="text" id="phone" name="phone" value="<%=phone%>" maxlength="10" onkeypress="return /[0-9]/.test(event.key)" required/>
                        </div>
                    
                        <div class="input-group">
                            <label>Contractor Aadhar No. <span class="mandatory">*</span></label>
                            <input type="text" id="adhar" name="adhar" value="<%=adhar%>" maxlength="12" onkeypress="return /[0-9]/.test(event.key)" required/>
                        </div>
                        <div class="input-group full-width">
                            <label>Contractor Address <span class="mandatory">*</span></label>
                            <input type="text" id="address" name="address" value="<%=contractorAddress%>" onkeyup="capLtr(this.value,'address')" required/>
                        </div>
                        
                        <div class="input-group full-width">
                            <label>Description</label>
                            <input type="text" id="desp" name="desp" value="<%=desp%>" onkeyup="capLtr(this.value,'desp')"/>
                        </div>

                        <div class="button-container">
                            <input type="submit" value="Update Contract Details"/>
                            <input type="reset" value="Reset Form"
                                onclick="window.location.reload();"/>
                        </div>

                    </div>
                </form>
            </div>

            <div>
                <div class="upload-panel">
                    <h3>Update Contract Document</h3>

                    <div class="upload-box">
                        <div style="font-weight: 600; margin-bottom: 8px;">Upload New/Replace Document:</div>
                        <div style="display:flex; gap:10px;">
                            <input type="file" id="DocumentFile" name="DocumentFile"
                                accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" style="flex:1;" onchange="handleDocumentAdd()">
                            <button type="button" onclick="handleDocumentAdd()" disabled>Add</button>
                        </div>

                        <div id="documentPreview" class="file-preview-area">
                            </div>

                        <div style="margin-top:12px; font-size:13px;">
                            <b>Current Document Status:</b><br>
                            <span style="color:#007bff;"><%= documentExists ? "Document saved in database." : "No document currently saved." %></span><br>
                            <span style="color:#666;">Max size 5MB</span>
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>
<% } else if (id == null || id.trim().isEmpty()) { %>
    <div class="message-box info">
        ⬅️ Please enter the **Contract ID** above and click 'Fetch Details' to load the contract for updating.
    </div>
<% } %>

</body>
</html>