<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %> 
<%@ page import="java.text.*" %> 
<%@ page language="java" import="gatepass.Database.*" %>
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
<html>
<head>
    <title>display data from the table using jsp</title>
    	<style>
    
body {
	font-family: "Segoe UI", Arial, sans-serif;
	background: linear-gradient(135deg, #dfe9f3, #ffffff);
	margin: 0;
	padding: 30px;
}

</style>
</head>
<body>

<%
	String officertomeet= request.getParameter("officertomeet");
	System.out.println("officertomeet-"+officertomeet);
	
	
	
	
//	SimpleDateFormat format1 = new SimpleDateFormat("MM-dd-yyyy");
  //  SimpleDateFormat format2 = new SimpleDateFormat("dd-MMM-yy");
    //Date date = format1.parse(fromdate);
    //System.out.println(format2.format(fromdate));
    //System.out.println(format2.format(todate));
    
	//DateFormat formatter ; 
 //Date fdate,tdate; 
 // formatter = new SimpleDateFormat("dd-MMM-yy");
 // fdate = (Date)formatter.parse(fromdate); 
  //System.out.println("fromdate-__"+fdate); 
 // tdate = (Date)formatter.parse(todate);
  //System.out.println("fromdate-__"+tdate);
	
	 Connection conn = null;
	gatepass.Database db = new gatepass.Database();	
	conn = db.getConnection();
	
      try {
    

String ip = db.getServerIp();
ResultSet rs;
Statement st = conn.createStatement();
	rs= st.executeQuery("select * from visitor where OFFICERTOMEET= '"+officertomeet+"' order by id desc" ); //where id ='"+id+"'
%>	
	<h2>Details of visitors to meet :-<%=officertomeet %></h2>
   <TABLE cellpadding="15" border="1" style="background-color: #E6E6E6;">		
		 	 <TR> <th>VISITOR ID</th><th>NAME</th>
  <th> ADDRESS  </th>
    <th>CONTACT NUMBER  </th>
     <th>DATE OF VISITt</th>
    <th>TIME OF VISIT</th>
      <th>VISITOR</th>
     
   <th>PURPOSE</th>
 				  <th>MATERIAL</th>
   
     
    </TR>
		<%
    while (rs.next()) {
     %>
   
     <TR>       <td><%=rs.getString(11) %></td>
     
      
        <TD><%=rs.getString(1).toUpperCase()%> </TD>
         <TD><%=rs.getString(2)%><br><%=rs.getString(14)%><BR><%=rs.getString(13)%><br><%=rs.getString(15) %></TD>
   		   		<TD><%=rs.getString(16)%></TD>
   		
   		<TD><%=rs.getString(12)%></TD>
        <TD><%=rs.getString(10)%></TD>
          <td ><a href="http://<%=ip %>/visitor/name?id=<%=rs.getString(11) %>"><img src="http://10.3.122.199:8081/visitor/name?id=<%=rs.getString(11) %>" alt="" name="image5" width="100" height="70" /> </a></td>
        
         <TD><%=rs.getString(7)%></TD>
        <TD><%=rs.getString(3)%></TD>
       
    </TR>

    <%  
    }   
    rs.close();
    conn.close();    
} 
catch (Exception ex) 
{System.out.print(ex);}
    %>	
			</TABLE>
      </body>
</html>
      
