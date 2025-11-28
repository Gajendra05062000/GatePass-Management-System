<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.io.*" %>
<%@ page language="java" import="gatepass.Database.*" %>





<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" >
<html>
<head>

<%
	String id=request.getParameter("id");
  System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+id);
  
  Connection conn = null;
    	Statement st=null;
    	
    	gatepass.Database db = new gatepass.Database();	
		conn = db.getConnection();
		st=conn.createStatement();
		ResultSet rs = st.executeQuery("select * from visitor where id='"+id+"'"); // Executing the Query
		while(rs.next()){
    		System.out.println("hellooo");
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
<div id="container">
<div id="bv_Image2" style="margin:0;padding:0;position:absolute;left:125px;top:55px;width:67px;height:15px;text-align:left;z-index:0;">
<img src="gatepass.jpg" id="Image2" alt="" align="top" border="0" style="width:67px;height:15px;"></div>
<div id="bv_Image3" style="margin:0;padding:0;position:absolute;left:0px;top:0px;width:66px;height:50px;text-align:left;z-index:1;">
<img src="logo.jpg" id="Image3" alt="" align="top" border="0" style="width:64px;height:45px;"></div>
<div id="bv_Image4" style="margin:0;padding:0;position:absolute;left:58px;top:0px;width:240px;height:53px;text-align:left;z-index:2;">
<img src="logo.png" id="Image4" alt="" align="top" border="0" style="width:240px;height:53px;"></div>
<div id="bv_Image5" style="margin:0;padding:0;position:absolute;left:195px;top:72px;width:96px;height:78px;text-align:left;z-index:3;">
<img src="http://10.3.121.121:8080/visitor/name?id=<%=id%>" id="Image5" alt="" align="top" border="0" style="width:96px;height:78px;"></div>
<div id="bv_Image1" style="margin:0;padding:0;position:absolute;left:0px;top:315px;width:366px;height:115px;text-align:left;z-index:4;">
<img src="bottom.png" id="Image1" alt="" align="top" border="0" style="width:366px;height:115px;"></div>
<div id="bv_Image6" style="margin:0;padding:0;position:absolute;left:00px;top:265px;width:300px;height:50px;text-align:left;z-index:5;">
<img src="statement.png" id="Image6" alt="" align="top" border="0" style="width:300px;height:50px;"></div>
<div id="bv_Image7" style="margin:0;padding:0;position:absolute;left:190px;top:245px;width:105px;height:12px;text-align:left;z-index:6;">
<img src="officergatesign.png" id="Image7" alt="" align="top" border="0" style="width:105px;height:12px;"></div>
<div id="bv_Image8" style="margin:0;padding:0;position:absolute;left:00px;top:245px;width:66px;height:15px;text-align:left;z-index:7;">
<img src="signvisitor.png" id="Image8" alt="" align="top" border="0" style="width:66px;height:15px;"></div>
</div>
<div id="bv_Image9" style="margin:0;padding:0;position:absolute;left:210px;top:148px;width:29px;height:46px;text-align:left;z-index:8;">
<img src="datetime.png" id="Image9" alt="" align="top" border="0" style="width:29px;height:30px;"></div>
<div id="bv_Table1" style="margin:0;padding:0;position:absolute;left:0px;top:73px;width:150px;height:65px;text-align:left;z-index:9;">
<table style="position:absolute;width:150px;height:50px;z-index:9;" cellpadding="0" cellspacing="0" id="Table1">
<tr>
<td align="left" valign="top" style="height:13px;">
<font  style="font-size:13px;font-style: oblique; " ><%=rs.getString(1).toUpperCase() %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="height:9px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(16) %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="height:9px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(2).toUpperCase() %><br><%=rs.getString(14).toUpperCase() %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="height:17px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(13).toUpperCase() %><br><%=rs.getString(15) %></font>
</td>
</tr>
</table></div>
<div id="bv_Table2" style="margin:0;padding:0;position:absolute;left:00px;top:160px;width:100px;height:80px;text-align:left;z-index:10;">
<table style="position:absolute;width:200px;height:35px;z-index:10;" cellpadding="0" cellspacing="0" id="Table2">
<tr>
<td align="left" valign="top" style="width:100px;height:15px;">
<font style="font-size:12px" color="#000000" face="Kruti Dev 676">dz- la-</font></td>
<td align="left" valign="top" style="height:15px;">
<font  style="font-size:12px;font-style: oblique; " ><%=id %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="width:100px;height:15px;">
<font style="font-size:12px" color="#000000" face="Kruti Dev 676">ftl vf?kdkjh ls feyuk gS </font></td>
<td align="left" valign="top" style="height:15px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(5).toUpperCase() %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="width:100px;height:15px;">
<font style="font-size:12px" color="#000000" face="Kruti Dev 672">mn~ns';</font></td>
<td align="left" valign="top" style="height:15px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(7).toUpperCase() %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="width:100px;height:15px;">
<font style="font-size:12px" color="#000000" face="Kruti Dev 676">lkeku] ;fn dksbZ gks</font></td>
<td align="left" valign="top" style="height:15px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(3).toUpperCase() %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="width:100px;height:15px;">
<font style="font-size:12px" color="#000000" face="Kruti Dev 676">okgu] ;fn dksbZ gks</font></td>
<td align="left" valign="top" style="height:15px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(4).toUpperCase() %></font></td>
</tr>
</table></div>

<div id="bv_Table3" style="margin:0;padding:0;position:absolute;left:250px;top:150px;width:82px;height:30px;text-align:left;z-index:11;">
<table style="position:absolute;width:82px;height:30px;z-index:11;" cellpadding="0" cellspacing="0" id="Table3">
<tr>
<td align="left" valign="top" style="height:8px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(12) %></font></td>
</tr>
<tr>
<td align="left" valign="top" style="height:8px;">
<font  style="font-size:8px;font-style: oblique; " ><%=rs.getString(10) %></font></td>
</tr>
</table></div>

<script language="javascript" src="print.js">

		</script>
<input type="submit"  name="print" value="print" style="position:absolute;left:425px;top:350px;width:75px;height:24px;font-family:Arial;font-size:13px;z-index:68" onClick='printPage()'>


</body>
<%}rs.close();conn.close();  %>
</html>