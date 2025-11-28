package gatepass;

import java.io.InputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.sql.Types; // Needed for setNull

@WebServlet("/UpdateContract")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UpdateContract extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        System.out.println("➡ UpdateContract.doPost invoked");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;
        PreparedStatement ps = null;
        
        // File handling variables
        Part filePart = null;
        InputStream fileContent = null;
        long fileSize = 0;
        
        // Hidden field to determine document action (KEEP, REPLACE, REMOVE)
        String docAction = getParam(request, "docAction", "KEEP");

        try {
            
            // --- 1. Retrieve Form Fields ---
            int id = parseIntOrDefault(request.getParameter("id"), -1); 
            if (id == -1) {
                 throw new IllegalArgumentException("Contract ID is missing or invalid.");
            }
            
            String name = getParam(request, "name", "");
            String ContractorName = getParam(request, "Contractor", "");
            String dept = getParam(request, "dept", "");
            String address = getParam(request, "address", "");
            String phone = getParam(request, "phone", "");
            String adhar = request.getParameter("adhar"); 
            String reg = getParam(request, "reg", "");
            String desp = getParam(request, "desp", "");
            String valdity_fromDate = getParam(request, "valdity_fromDate", "");
            String valdity_toDate = getParam(request, "valdity_toDate", "");
            String type = getParam(request, "type", "");
            int laboursize = parseIntOrDefault(request.getParameter("laboursize"), 0);
            
            // --- 2. Handle File Part based on docAction ---
            if (docAction.equals("REPLACE")) {
                // The file input name is 'DocumentFile' in the JSP
                filePart = request.getPart("DocumentFile"); 
                if (filePart != null && filePart.getSize() > 0) {
                    fileContent = filePart.getInputStream();
                    fileSize = filePart.getSize();
                } else {
                    // This scenario shouldn't happen if JS validation works, but defensive coding is good.
                    docAction = "KEEP"; // Revert to keep if no file was actually uploaded.
                    System.out.println("WARN: Document action was REPLACE but no file was received.");
                }
            }
            
            // --- 3. Build Dynamic SQL UPDATE Query ---
            // Base update query without the Document field
            String sql = "UPDATE GATEPASS_CONTRACT SET "
                       + "CONTRACT_NAME=?, CONTRACTOR_NAME=?, DEPARTMENT=?, CONTRACTOR_ADDRESS=?, "
                       + "DESCRIPTION=?, CONTRACTOR_ADHAR=?, "
                       + "VALIDITY_FROM=TO_DATE(?, 'YYYY-MM-DD'), VALIDITY_TO=TO_DATE(?, 'YYYY-MM-DD'), "
                       + "CONTRACT_TYPE=?, REGISTRATION=?, UPDATE_DATE=?, UPDATE_BY=?, PHONE=?, LABOUR_SIZE=? ";
            
            if (docAction.equals("REPLACE")) {
                sql += ", DOCUMENT1=? "; // Add DOCUMENT1 BLOB placeholder
            } else if (docAction.equals("REMOVE")) {
                sql += ", DOCUMENT1=NULL "; // Explicitly set BLOB to NULL
            }
            
            sql += "WHERE ID=?"; // Final condition

            // --- 4. DB Connection and Preparation ---
            Database db = new Database();
            conn = db.getConnection();
            ps = conn.prepareStatement(sql);

            // --- 5. Set Parameters (Order depends on docAction) ---
            int idx = 1;
            
            ps.setString(idx++, name);
            ps.setString(idx++, ContractorName);
            ps.setString(idx++, dept);
            ps.setString(idx++, address);
            ps.setString(idx++, desp);
            ps.setString(idx++, adhar);
            ps.setString(idx++, valdity_fromDate);
            ps.setString(idx++, valdity_toDate);
            ps.setString(idx++, type);
            ps.setString(idx++, reg);
            
            CommonService cs = new CommonService();
            ps.setString(idx++, cs.selectDateTime().toString()); // UPDATE_DATE
            ps.setString(idx++, "NA"); // UPDATE_BY
            ps.setString(idx++, phone);
            ps.setInt(idx++, laboursize);
            
            // Handle Document BLOB parameter
            if (docAction.equals("REPLACE")) {
                ps.setBinaryStream(idx++, fileContent, fileSize);
            }
            // Note: If docAction is "REMOVE", DOCUMENT1=NULL is hardcoded in the SQL.
            
            // Set WHERE clause parameter
            ps.setInt(idx++, id); 
            
            // --- 6. Execute Update ---
            int result = ps.executeUpdate();
            
            if (result == 1) {
                System.out.println("✅ Contract Updated successfully. Contract ID: " + id);
                // Display success message and redirect back to the edit page (or a success view)
                out.println("<script>");
                out.println("alert('Contract Updated Successfully!');");
                out.println("window.location.href='PrintContract.jsp?id=" + id + "';");
                out.println("</script>");
            } else {
                out.println("<h3>❌ Failed to Update Data. Contract ID " + id + " not found or zero rows affected.</h3>");
            }

        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            out.println("<h3>Database Error: Failed to update contract.</h3>");
            out.println("<h4>Error Details: " + e.getMessage() + "</h4>");
            // Optional: Redirect back to the form with an error parameter
            // response.sendRedirect("editContract.jsp?id=" + request.getParameter("id") + "&error=" + e.getErrorCode());
        } catch (Exception e) {
            System.err.println("General Error: " + e.getMessage());
            out.println("<h3>General Error: " + e.getMessage() + "</h3>");
        } finally {
            // --- 7. Resource Cleanup ---
            if (fileContent != null) try { fileContent.close(); } catch (IOException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }

    // Utility methods (copied from SaveContract)
    private int parseIntOrDefault(String val, int def) {
        try { return (val == null || val.trim().isEmpty()) ? def : Integer.parseInt(val.trim()); } 
        catch (NumberFormatException e) { return def; }
    }

    private String getParam(HttpServletRequest req, String key, String def) {
        String v = req.getParameter(key);
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }
}