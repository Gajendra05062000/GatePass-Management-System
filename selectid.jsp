<%@ page language="java" pageEncoding="ISO-8859-1"%>

<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title></title>
    
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
		<style>
    
body {
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f4f7f6;;
	margin: 0;
	padding: 30px;
}</style>
  </head>
  
  <body > <form action="My.jsp" method="get" 
      style="position:absolute;left:40%;  width:350px; height:40px; z-index:31; 
             display:flex; align-items:center; justify-content:center; gap:10px; 
             background:#f8f9fa; border-radius:8px; padding:8px; box-shadow:0 2px 6px rgba(0,0,0,0.1);">

  <label for="id" style="font-family:Segoe UI; font-size:14px; color:#333;">Visitor ID:</label>
  <input type="text" id="id" name="id" 
         style="padding:6px 8px; border:1px solid #ccc; border-radius:5px; width:150px; font-size:14px;" 
         placeholder="Enter Visitor  ID">
  <input type="submit" name="view" value="View" 
         style="padding:6px 15px; border:none; border-radius:5px; background:#1e3c72; color:white; font-size:14px; cursor:pointer;">
</form>
  

  </body>
</html>
