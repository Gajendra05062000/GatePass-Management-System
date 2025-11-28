<%-- 
    Document   : PrintForeignerGatePass
    Created on : 30 October, 2025, 11:08:04 AM
    Author     : Gajendra Jatav
--%>
<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.io.*" %>
<%@ page language="java" import="gatepass.Database.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" >
<html>

<head>

   <script type="text/javascript" language="javascript">
   
function printPage(){
   var printButton = document.getElementById("printPageButton");
        //Set the print button visibility to 'hidden' 
        printButton.style.visibility = "hidden";
        //Print the page content
window.print();
printButton.style.visibility = "visible";

}


function printPagePopUp(refNo){ 

var iMyWidth;
            var iMyHeight;
            //half the screen width minus half the new window width (plus 5 pixel borders).
            iMyWidth = 100;
            //half the screen height minus half the new window height (plus title and status bars).
            iMyHeight = 200;
  

//newwindow=window.open(refNo,'print',"status=no,height=450,width=300,resizable=yes,left=" + iMyWidth + ",top=" + iMyHeight + ",screenX=" + iMyWidth + ",screenY=" + iMyHeight + ",toolbar=no,menubar=no,scrollbars=no,location=no,directories=no");
newwindow=window.open(refNo,'print','left=8,right=8,height=470,width=340');
   // newwindow=window.open('PrintContractLabourPopUp.jsp?srNo=3','print','height=400,width=300');   
    if (window.focus) {newwindow.focus()
    }   //to set focus on new opened window  
    newwindow.print(); 
}
		</script>
<%
String srNo=request.getParameter("srNo").toString();
//String srNo=request.getAttribute("srNo").toString();
	Connection conn1 = null;
    	Statement st1=null;
    	int id=0;
    	gatepass.Database db1 = new gatepass.Database();	
		conn1 = db1.getConnection();
		st1=conn1.createStatement();
		ResultSet rs1 = st1.executeQuery("select max(SER_NO) from GATEPASS_FOREIGNER"); // Executing the Query
		while(rs1.next()){
    		
    	id=rs1.getInt(1);
    	System.out.println("GATEPASS_FOREIGNER Max Ser No is-"+id);
        }
       
%>

<%
	Connection conn = null;
    	Statement st=null;
 	gatepass.Database db = new gatepass.Database();	
	conn = db.getConnection();
	String ip = db.getServerIp();
		st=conn.createStatement();
		String qry = "SELECT SER_NO,VISIT_DEPT,WORKSITE,NAME,FATHER_NAME,DESIGNATION,AGE,LOCAL_ADDRESS,PERMANENT_ADDRESS,NATIONALITY,TO_CHAR(VALIDITY_PERIOD_FROM,'DD-MON-YYYY'),TO_CHAR(VALIDITY_PERIOD_TO,'DD-MON-YYYY'),PHOTO_IMAGE,to_char(sysdate,'MM-MON-YYYY') FROM GATEPASS_FOREIGNER where SER_NO='"+srNo+"'";
		System.out.println("Select all data from Qry--"+qry);
                ResultSet rs = st.executeQuery(qry); // Executing the Query
		while(rs.next()){
    		
%>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Untitled Page</title>
<meta name="GENERATOR" content="Created by BlueVoda Website builder http://www.bluevoda.com">
<meta name="HOSTING" content="Hosting Provided By VodaHost http://www.vodahost.com">
<style type="text/css">
div#container
{
   width: 800px;
   height: 600px;
   margin-top: 0px;
   margin-left: 0px;
   text-align: left;
}
<style type="text/css" media="print">
        @page 
        {
            size: auto;   /* auto is the initial value */
            margin: 0mm;  /* this affects the margin in the printer settings */
        }
        footer {
  text-align: center;
  font-size: 12px;
  color: #777;
  margin-top: 15px;
}
</style>
<style type="text/css">
body
{
   background-color: #FFFFFF;
   color: #000000;
}
</style>


<style type="text/css">
a:hover
{
   color: #C988A3;
}
</style>
<!--[if lt IE 7]>
<style type="text/css">
   img { behavior: url("pngfix.htc"); }
</style>
<![endif]-->
</head>
<body>

<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="320" height="450">
  <tr>
    <td width="100%" height="30" colspan="10">
    <p align="center">FOREIGNER GATE PASS</td>
  </tr>
  <tr>
    <td width="70%" height="19" colspan="7"><font size="2">Foreigner Gate Pass Ser No. -</font> </td>
    <td width="30%" height="19" colspan="3"><font  size="4">&nbsp;&nbsp;&nbsp;<%=rs.getString(1) %></font> </td>
  </tr>
  <tr>
    <td width="40%" height="19" colspan="4"><font size="3"><font  size="2">Visiting Dept:</font></td>
    <td width="60%" height="19" colspan="6"><font  size="1"><%=rs.getString(2) %></font> </td>
  </tr>
  <tr>
    <td width="100%" height="19" colspan="10" align="center"><font  size="2" >(Work Site: NFL, Panipat)</font></td>
  </tr>
  <tr>
    <td width="20%" height="19" colspan="2"><font size="2">Name : </font></td>
    <td width="80%" height="19" colspan="8"><font size="1"><%=rs.getString(4) %></font> </td>
  </tr>
  <tr>
    <td width="30%" height="16" colspan="3"><font size="2">Father's Name : </font></td>
    <td width="30%" height="16" colspan="3"><font size="1"><%=rs.getString(5) %></font></td>
    <td width="40%" height="90" colspan="4" rowspan="5" align="center"><img src="ShowImageForeigner.jsp?srNo=<%=rs.getString(1) %>" id="Image5" align="middle" border="0" style="width:100px;height:85px;"></td>
  </tr>
  <tr>
    <td width="30%" height="19" colspan="3"><font size="1"><font size="2"><font size="2">Designation : </font></font></font></td>
    <td width="30%" height="19" colspan="3"><font size="1"><%=rs.getString(6) %></font></td>
  </tr>
  <tr>
    <td width="20%" height="19" colspan="2"><font size="2">Age : </font></td>
    <td width="40%" height="19" colspan="4"><font size="1"><%=rs.getString(7) %></font></td>
  </tr>

  <tr>
    <td width="30%" height="19" colspan="3"><font size="2">Local Address: </font></td>
    <td width="70%" height="19" colspan="7"><font size="1"><%=rs.getString(8) %></font></td>
  </tr>
  <tr>
    <td width="30%" height="19" colspan="3"><font size="2">Permanent Address: </font></td>
    <td width="70%" height="19" colspan="7"><font size="1"><%=rs.getString(9) %></font></td>
  </tr>

    <tr>
    <td width="30%" height="19" colspan="3"><font size="2">Nationality :</font></td>
    <td width="70%" height="19" colspan="7"><font size="1"><%=rs.getString(10) %></font></td>
  </tr>
  
  <tr>
    <td width="30%" height="19" colspan="3"><font size="2">Date of Issue : </font></td>
    <td width="70%" height="19" colspan="7"><font size="1"><%=rs.getString(14) %></font></td>
  </tr>
  <tr>
    <td width="30%" height="19" colspan="3"><font size="2">Valid Up To : </font></td>
    <td width="70%" height="19" colspan="7"><font size="1"><%=rs.getString(11) %> - </font>  <font size="1"><%=rs.getString(12) %></font></td>
  </tr>
 
   <tr>
    <td width="100%" height="10" colspan="10">
   </td>
  </tr>
  
  
    <tr>
    <td width="50%" height="19" colspan="5"><font size="1">Sign Of the Card Holder</font></td>
    <td width="50%" height="19" colspan="5"><font size="1">Sign Of Issuing Authority with Stamp</font></td>
  </tr>
  <tr>
    <td width="100%" height="19" colspan="10" align="center"><font  size="3" >INSTURCTION</font></td>
  </tr>
  <tr>
<td width="100%" height="19" colspan="10" align="left"><font  size="1" >1. This card may be produced before the security staff as and when when demanded.</font></td>
  <tr>
<td width="100%" height="19" colspan="10" align="left"><font  size="1" >2. This card is not transferable.</font></td>
   </tr>
     <tr>  
<td width="100%" height="19" colspan="10" align="left"><font  size="1" >3. Loss of card may please be reported immediately to the issuing authority.</font></td>
    </tr>
      <tr> 
 <td width="100%" height="19" colspan="10" align="left"><font  size="1" >4. the contractor does not guarantee the cardholder employment. This only permits him to enter factory premises, as and when 
 required by the contractor. </font></td>
   
  </tr>
  <tr>
    <td width="100%" height="10" colspan="10">&nbsp;</td>
  </tr>

  <tr>
    <td width="100%" height="87" colspan="10">&nbsp;</td>
  </tr>
  <tr><td colspan="10" align="center"><a href="PrintForeignerGatePassPopUp.jsp?srNo=<%=rs.getInt(1) %>" onClick="printPagePopUp(this)">Print

</td></tr>	
</table>

<footer>© 2025 Gate Pass Management System | NFL Panipat</footer>
</body>
<% } rs.close();conn.close();
 conn1.close();
 %>
</html>
