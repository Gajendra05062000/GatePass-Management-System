<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %> 
<%@ page import="java.text.*" %> 
<html>
<head>
    <title>display data from the table using jsp</title>
</head>
<body bg-color="linear-gradient(135deg, #dfe9f3, #ffffff);">

<%		String state= request.getParameter("state");
	System.out.println("state-__"+state); 
	
	%>
	<a href="http://10.3.122.199:8081/visitor/name?id=<%=state %>" >VIEW VISITOR having id&nbsp;&nbsp; :=&nbsp;&nbsp;<%=state %></a>
	 
	

     
			
      </body>
</html>
      
