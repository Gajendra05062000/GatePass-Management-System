<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %> 
<html>
<head>
    <title>display data from the table using jsp</title>
</head>
<body>
<h2>Data and image from the table image1</h2>
<%
	String id= request.getParameter("id");

      try {
     Connection conn = null;
gatepass.Database db = new gatepass.Database();	
	conn = db.getConnection();
		String name = null;
ResultSet rs;
Statement st = conn.createStatement();
	rs= st.executeQuery("select * from image1  where id ='"+id+"'" );
%>	
	<TABLE cellpadding="15" border="1" style="background-color: #ffffcc;">		
		 <TR><th>ID</th>
    <th>IMAGE</th>
    <th>NAME</th>
    </TR>
		<%
    while (rs.next()) {
    %>
   
    <TR>
        
        <TD><%=rs.getString(1)%></TD>
          //<td align="left" width="100px" height="70" rowspan="0" colspan="0" bgcolor="#80ff80" bordercolor="#400040"><img src="http://cc:8080/StoreImage/test?id=<%=request.getParameter("id") %>" alt="" name="image5" width="100" height="70" /> </td>
        <TD><%=rs.getString(3)%></TD>
    </TR>
    <% rs.close();conn.close();   }    %>
     <%
   
} catch (Exception ex) {System.out.print(ex);}
    %>	
			</TABLE>
      </body>
</html>
      
