<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="gatepass.Database" %>
<%@ page import="java.io.IOException" %> 
<%@ page import="java.text.*" %> 
<%@ page import="java.util.Date" %>


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

<%!
// Define the column names for the table headers
private static final String[] HEADERS = {
    "Visitor ID", "Photo", "Name", "Father Name", "Address", "Contact", "Date of Visit", "Time", "Officer to Meet", "Purpose", "Material", "Action"
};
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Visitor Records by State</title>
    
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="expires" content="0">

    <style>
        /* Base Styling */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; padding: 20px; color: #333; }
        h3 { color: #1e3c72; text-align: center; margin-top: 10px; margin-bottom: 25px; text-transform: uppercase; }
        
        /* --- FORM STYLING (Modernized) --- */
        #stateForm {
            background: #ffffff;
            max-width: 700px;
            margin: 0 auto 30px; 
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .form-row {
            display: flex;
            gap: 20px;
            align-items: flex-end;
            justify-content: space-between;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        
        .form-group label {
            font-size: 14px;
            color: #333;
            margin-bottom: 5px;
            font-weight: bold;
        }

        #stateForm select {
            padding: 10px 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 15px;
            height: 40px;
            box-sizing: border-box;
            width: 100%;
        }

        #stateForm input[type="submit"] {
            background-color: #1e3c72;
            color: #fff;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background 0.3s ease, transform 0.1s;
            font-size: 15px; 
            font-weight: bold;
            height: 40px;
            padding: 0 20px;
            box-sizing: border-box;
            width: 150px;
        }

        #stateForm input[type="submit"]:hover {
            background-color: #0056b3;
            transform: scale(1.02);
        }
        /* --- END FORM STYLING --- */

        /* --- TABLE & SEARCH STYLING --- */
        #searchInput {
            width: 100%;
            padding: 12px 20px;
            margin-bottom: 20px;
            box-sizing: border-box;
            border: 2px solid #ccc;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        #searchInput:focus {
            border-color: #007bff;
            outline: none;
        }

        #visitorTable { 
            border-collapse: collapse; 
            width: 100%; 
            margin-top: 20px; 
            box-shadow: 0 4px 8px rgba(0,0,0,0.1); 
            border-radius: 8px; 
            overflow: hidden; 
            background-color: white;
        }
        #visitorTable th { 
            background-color: #1e3c72; 
            color: white; 
            padding: 12px 15px; 
            text-align: left; 
            font-size: 15px; 
            font-weight: bold;
            border: none; 
        } 
        #visitorTable td { 
            border: 1px solid #ddd; 
            padding: 10px 15px; 
            text-align: left; 
            font-size: 14px; 
            background-color: #ffffff; 
            color: #333;
        }
        #visitorTable tr:nth-child(even) td {
            background-color: #f9f9f9; 
        }
        #visitorTable tr:hover td {
            background-color: #e0f7fa; 
            cursor: default;
        }
        #visitorTable td a {
            color: #007bff;
            text-decoration: none;
            font-weight: 600;
        }
        #visitorTable td a:hover {
            text-decoration: underline;
        }
        
        img { display: block; max-width: 80px; height: 100px; object-fit: cover; border-radius: 4px; }
        .error-message {
            text-align: center;
            color: red;
            font-weight: bold;
            padding: 20px;
        }
    </style>
</head>

<body>
<%
// 1. Get and define parameter
String selectedState = request.getParameter("state");

// Flag to check if the result table should be rendered
boolean showResults = (selectedState != null && !selectedState.isEmpty());

// ----------------------
// JavaScript Functions
// ----------------------
%>
<script>
    function ValidateStateForm(form) {
        if (form.state.value === "") {
            alert("Please select a State to view records.");
            return false;
        }
        return true; 
    }
    
    // Loads the visitor card into the main dashboard frame
    function loadPrintPageInMainFrame(visitorId) { 
        // Note: Assuming the print page is print_visitor_card.jsp (as used in previous templates)
        const url = "print_visitor_card.jsp?id=" + visitorId; 
        
        if (window.parent && window.parent.right) {
            window.parent.right.location.href = url;
        } else {
            window.location.href = url;
        }
    }
    
    // Search function for the results table
    function filterTable() {
        var input, filter, table, tr, td, i, j, txtValue;
        input = document.getElementById("searchInput");
        filter = input.value.toUpperCase();
        table = document.getElementById("visitorTable");
        tr = table.getElementsByTagName("tr");

        for (i = 1; i < tr.length; i++) {
            var rowMatch = false;
            td = tr[i].getElementsByTagName("td");
            for (j = 0; j < td.length; j++) {
                if (td[j]) {
                    txtValue = td[j].textContent || td[j].innerText;
                    if (txtValue.toUpperCase().indexOf(filter) > -1) {
                        rowMatch = true;
                        break; 
                    }
                }
            }
            
            if (rowMatch) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }
</script>

<!-- === 1. STATE SELECTION FORM === -->
<h3>📍 View Visitor Records by State</h3>

<form name="selectStateForm" method="get" action="<%= request.getRequestURI() %>" id="stateForm" onsubmit="return ValidateStateForm(this)">
    <div class="form-row">
        <div class="form-group">
            <label for="state">Select State:</label>
            <select name="state" id="state" required>
                <option value="" <%= (selectedState == null || selectedState.isEmpty()) ? "selected" : "" %> disabled>-- Select State --</option>
                <%
                    // Full list of Indian states/UTs for the dropdown
                    String[] states = {
                        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", 
                        "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", 
                        "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", 
                        "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan", 
                        "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", 
                        "Uttarakhand", "West Bengal", "Andaman and Nicobar Islands", "Chandigarh", 
                        "Dadra and Nagar Haveli and Daman and Diu", "Delhi", "Lakshadweep", "Puducherry"
                    };
                    
                    for (String stateName : states) {
                %>
                        <option value="<%= stateName %>" <%= stateName.equals(selectedState) ? "selected" : "" %>><%= stateName %></option>
                <%
                    }
                %>
            </select>
        </div>

        <div class="form-group" style="flex-grow: 0;">
            <input type="submit" value="View Records">
        </div>
    </div>
</form>

<%
// === 2. RESULTS TABLE (Rendered only if state is selected) ===
if (showResults) {
    Connection conn = null;
    Statement st = null; 
    ResultSet rs = null;

    try {
        Database db = new Database();	
        conn = db.getConnection();

        // Query visitors for the selected state
        String sql = "SELECT ID, NAME, FATHERNAME, ADDRESS, DISTRICT, STATE, PINCODE, PHONE, " +
                     "TO_CHAR(ENTRYDATE, 'DD-MON-YYYY') AS ENTRYDATE, TIME, OFFICERTOMEET, PURPOSE, MATERIAL " +
                     "FROM visitor WHERE STATE = '" + selectedState + "' ORDER BY id DESC";
        
        st = conn.createStatement();
        rs = st.executeQuery(sql);
%>
    
    <hr style=" border-top: 2px solid #ccc;">

    <h3>Visitor Records from <%= selectedState %></h3>
    
    <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search by name, ID, contact, officer, or purpose...">

    <TABLE id="visitorTable" cellpadding="0" cellspacing="0">		
        <thead>
            <TR> 
                <% for (String header : HEADERS) { %>
                    <th><%= header %></th>
                <% } %>
            </TR>
        </thead>
        <tbody>
        
        <%
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
        %>
        
        <TR>    
            <!-- Visitor ID -->
            <td>NFL/CISF/VISITOR/0<%=rs.getString("ID") %></td>
            
            <!-- Photo -->
            <td >
                <a href="ShowVisitor.jsp?id=<%=rs.getString("ID") %>" target="_blank">
                    <img src="ShowVisitor.jsp?id=<%=rs.getString("ID") %>" alt="Visitor Photo" /> 
                </a>
            </td>
            
            <!-- Name, Father Name -->
            <TD><%=rs.getString("NAME") != null ? rs.getString("NAME").toUpperCase() : "" %></TD>
            <td><%=rs.getString("FATHERNAME") %></td>
            
            <!-- Address (Consolidated) -->
            <TD>
                <%=rs.getString("ADDRESS")%><br>
                <%=rs.getString("DISTRICT")%>, <%=rs.getString("STATE")%> - <%=rs.getString("PINCODE") %>
            </TD>
            
            <!-- Contact, Date, Time -->
            <TD><%=rs.getString("PHONE")%></TD>
            <TD><%=rs.getString("ENTRYDATE")%></TD>
            <TD><%=rs.getString("TIME")%></TD>

            <!-- Officer, Purpose, Material -->
            <TD><%=rs.getString("OFFICERTOMEET")%></TD>
            <TD><%=rs.getString("PURPOSE")%></TD>
            <TD><%=rs.getString("MATERIAL")%></TD>
            
            <!-- Action -->
            <td>
                <a href="javascript:void(0);" onclick="loadPrintPageInMainFrame('<%= rs.getString("ID") %>');"> 
                    View pass 
                </a>
            </td>
        </TR>

        <%    } // end while loop %>
        
        <% if (rowCount == 0) { %>
            <tr><td colspan="<%= HEADERS.length %>" class="error-message">No records found for the state: <%= selectedState %>.</td></tr>
        <% } %>
        </tbody>
    </TABLE>
    
<%
    } catch (SQLException ex) {
        System.err.println("SQL Error: " + ex.getMessage());
        out.println("<div class='error-message'>Database Error: " + ex.getMessage() + "</div>");
    } catch (Exception ex) {
        System.err.println("General Error: " + ex.getMessage());
        out.println("<div class='error-message'>A general error occurred: " + ex.getMessage() + "</div>");
    } finally {
        // 6. Resource Cleanup
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (st != null) try { st.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
} // end if (showResults)
%>	
</body>
</html>