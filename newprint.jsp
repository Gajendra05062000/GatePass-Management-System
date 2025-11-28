<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>My JSP 'newprint.jsp' starting page</title>
    
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->

  </head>
  
  <body>
    <div id="bv_Form1" style="position:absolute;background-color:#F0F0F0;width:347px;height:378px;">
<form name="Form1" method="post" action="" enctype="text/plain" id="Form1">
<div id="bv_Text1" style="margin:0;padding:0;position:absolute;left:81px;top:29px;width:150px;height:18px;text-align:center;z-index:69;">
<h6>Gate Pass</h6></div>
<div id="bv_Text2" style="margin:0;padding:0;position:absolute;left:34px;top:5px;width:245px;height:18px;text-align:center;z-index:70;">
<h6>National Fertilizers Ltd.</h6></div>
<div id="bv_Text3" style="margin:0;padding:0;position:absolute;left:21px;top:66px;width:166px;height:64px;text-align:left;z-index:71;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;name&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<div id="bv_Text4" style="margin:0;padding:0;position:absolute;left:22px;top:116px;width:150px;height:80px;text-align:left;z-index:72;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;address&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<div id="bv_Text5" style="margin:0;padding:0;position:absolute;left:21px;top:169px;width:100px;height:16px;text-align:left;z-index:73;">
<font style="font-size:13px" color="#000000" face="Arial">Allowed material</font></div>
<div id="bv_Image2" style="margin:0;padding:0;position:absolute;left:205px;top:78px;width:66px;height:74px;text-align:left;z-index:74;">
<img src="http://cc:8080/visitor/name?name=<%=request.getAttribute("name").toString() %>" id="Image2" alt="visitor image" align="top" border="0" style="width:66px;height:74px;"></div>
<div id="bv_Text7" style="margin:0;padding:0;position:absolute;left:217px;top:58px;width:121px;height:80px;text-align:left;z-index:75;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;date&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<div id="bv_Text8" style="margin:0;padding:0;position:absolute;left:20px;top:221px;width:53px;height:32px;text-align:left;z-index:76;">
<font style="font-size:13px" color="#000000" face="Arial"> To meet</font></div>
<div id="bv_Text9" style="margin:0;padding:0;position:absolute;left:155px;top:168px;width:150px;height:80px;text-align:left;z-index:77;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;material&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<div id="bv_Text6" style="margin:0;padding:0;position:absolute;left:23px;top:263px;width:150px;height:16px;text-align:left;z-index:78;">
<font style="font-size:13px" color="#000000" face="Arial">purpose</font></div>
<div id="bv_Text10" style="margin:0;padding:0;position:absolute;left:150px;top:219px;width:155px;height:80px;text-align:left;z-index:79;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;officertomeet&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<div id="bv_Text11" style="margin:0;padding:0;position:absolute;left:156px;top:263px;width:150px;height:80px;text-align:left;z-index:80;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;purpose&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<div id="bv_Text12" style="margin:0;padding:0;position:absolute;left:18px;top:296px;width:150px;height:16px;text-align:left;z-index:81;">
<font style="font-size:13px" color="#000000" face="Arial">Vehicle number</font></div>
<div id="bv_Text13" style="margin:0;padding:0;position:absolute;left:158px;top:295px;width:150px;height:80px;text-align:left;z-index:82;">
<font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">&lt;%=</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">request.getAttribute(</font><font style="font-size:13px;background-color:#E8F2FE" color="#2A00FF" face="Courier New">&quot;vehicle&quot;</font><font style="font-size:13px;background-color:#E8F2FE" color="#000000" face="Courier New">).toString() </font><font style="font-size:13px;background-color:#E8F2FE" color="#BF5F3F" face="Courier New">%&gt;</font></div>
<input type="submit" id="Button1" name="print" value="print" style="position:absolute;left:266px;top:336px;width:75px;height:24px;font-family:Arial;font-size:13px;z-index:83">
<div id="bv_Text14" style="margin:0;padding:0;position:absolute;left:16px;top:324px;width:90px;height:16px;text-align:left;z-index:84;">
<font style="font-size:13px" color="#000000" face="Arial">Visitor number</font></div>
<div id="bv_Text15" style="margin:0;padding:0;position:absolute;left:148px;top:323px;width:150px;height:16px;text-align:left;z-index:85;">
<font style="font-size:13px" color="#000000" face="Arial">visitornumber</font></div>
<div id="bv_Image1" style="margin:0;padding:0;position:absolute;left:262px;top:7px;width:81px;height:41px;text-align:left;z-index:86;">
<img src="C:\Users\cc\Desktop\nfl\logo.jpg" id="Image1" alt="logo" align="top" border="0" style="width:81px;height:41px;"></div>
</form>
</div>
 <script language="javascript" src="print.js">
		</script>
<input type="submit"  name="print" value="print" style="position:absolute;left:271px;top:338px;width:75px;height:24px;font-family:Arial;font-size:13px;z-index:68" onClick='printPage()'>
  </body>
</html>
