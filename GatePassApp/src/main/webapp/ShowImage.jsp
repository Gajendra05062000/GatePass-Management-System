<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.io.*" %>
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

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" >
<html>
<script language="javascript" src="print.js">

		</script>
<head>


<%
String srNo=request.getParameter("srNo").toString();
System.out.println("Showing image for  SerNo--"+srNo);
	Connection conn = null;
    	Statement st=null;
    	Blob img ;
     byte[] imgData = null ;
     
     try{
 	gatepass.Database db = new gatepass.Database();	
	conn = db.getConnection();
	String ip = db.getServerIp();
		st=conn.createStatement();
		ResultSet rs = st.executeQuery("SELECT SER_NO,PHOTO FROM GATEPASS_CONTRACT_LABOUR where SER_NO='"+srNo+"'"); // Executing the Query
		while(rs.next()){
    	
    	//img = rs.getBlob(2);
    	imgData = rs.getBytes(2);
       
    		
    
       // display the image
        response.setContentType("image/gif");
        OutputStream o = response.getOutputStream();
        o.write(imgData);
        o.flush(); 
        o.close();
        
      
     
    	}
    	rs.close();      
        conn.close();
    	}
    	catch(Exception e){
    	System.out.println("Error-"+e.toString());
    	e.printStackTrace();
    	}
    		

		
    		
    		
    		
%>
</html>