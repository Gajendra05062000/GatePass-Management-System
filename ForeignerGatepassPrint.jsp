<%@ page language="java" import="java.sql.*" %>
<%@page import="java.lang.*" %>
<%@page import="org.apache.commons.fileupload.FileItem" %>
<%@page import="org.apache.commons.fileupload.FileUploadException" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@page import="org.apache.commons.io.output.*" %>
<%@page import="java.io.*" %>
<%@page import="javaQuery.j2ee.GeoLocation" %>
<%@ page language="java" import="gatepass.Database.*" %>


<html>
	<script language="javaScript" type="text/javascript" src="calendar.js"></script>
	<script language="JavaScript" src="/visitor/javascript/FormValidation.js"></script>   
    <link href="calendar.css" rel="stylesheet" type="text/css">
    <script language="JavaScript" src="/visitor/javascript/datetimepicker.js"></script>   
   		   
<head>
<title>Gate Pass Entry Details</title>

<script type="text/javascript" language="javascript">


function printPagePopUp(refNo){ 
newwindow=window.open(refNo,'print','left=10,right=10,height=460,width=340');
   // newwindow=window.open('PrintContractLabourPopUp.jsp?srNo=3','print','height=400,width=300');   
    if (window.focus) {newwindow.focus()
    }   //to set focus on new opened window  
 newwindow.print(); 
}

function executeCommands(){
  WshShell = new ActiveXObject("Wscript.Shell"); //Create WScript Object
   WshShell.run("C://Users/cam.exe");
}

 </script>


</head>
<body bgcolor="#CED8F6" onload="executeCommands();" onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode}">


<div id="gatepass" style="position:absolute;background-color:#E6E6E6;left:50px;width:1000px;height:450px;">

<form action="/visitor/saveContractLabourDetails" method="post" name="text_form"
                        enctype="multipart/form-data"  onsubmit="return Blank_TextField_Validator()">

<table border=1>
<tr><td colspan="8" align="center"><font size="4" >CONTRACT LABOUR REGISTER</font>
</td></tr>

<tr><TD>SR.NO</TD><TD>NAME</TD><TD>FATHER NAME</TD><TD>DESIG</TD><TD>AGE</TD><TD>ADDRESS</TD><TD>IDENTIFICATION</TD><TD>VEHICLE NO.</TD><TD>ISSUE DATE</TD></tr>


<%
Connection conn1 = null;
    	Statement st1=null;
    	int id=0;
    	gatepass.Database db1 = new gatepass.Database();	
		conn1 = db1.getConnection();
		st1=conn1.createStatement();
		ResultSet rs1 = st1.executeQuery("select SER_NO,NAME,FATHER_NAME,DESIGNATION,AGE,LOCAL_ADDRESS,IDENTIFICATION,to_char(UPDATE_DATE,'DD-MON-YYYY'),VEHICLE_NO from GATEPASS_CONTRACT_LABOUR ORDER BY SER_NO DESC"); // Executing the Query
		while(rs1.next()){
    		System.out.println("hellooo");
    	id=rs1.getInt(1);

    %>	

<tr><TD><a href="\visitor\PrintContractLabourPopUp.jsp?srNo=<%=rs1.getInt(1) %>" onClick="printPagePopUp(this)"><%=rs1.getInt(1) %> </TD><TD><%=rs1.getString(2) %></TD><TD><%=rs1.getString(3) %></TD><TD><%=rs1.getString(4) %></TD><TD><%=rs1.getString(5) %></TD><TD><%=rs1.getString(6) %></TD><TD><%=rs1.getString(7) %></TD><TD><%=rs1.getString(9) %></TD><TD><%=rs1.getString(8) %></TD></tr>



<%
}
%>       
</table>


</form>

</div>


</body>
</html>