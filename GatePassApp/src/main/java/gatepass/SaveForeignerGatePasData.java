package gatepass;

import java.io.*;
import java.sql.*;
import java.util.Base64;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SaveForeignerGatePasData")
public class SaveForeignerGatePasData extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        System.out.println("✅ SaveForeignerGatePasData Servlet Initialized");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn=null;
        PreparedStatement ps = null;

        try {
            
            String imageBase64 = request.getParameter("imageData");
            if (imageBase64 == null || imageBase64.isEmpty()) {
                throw new Exception("Image data missing");
            }

            // Remove "data:image/png;base64," if included
            if (imageBase64.startsWith("data:image")) {
                imageBase64 = imageBase64.substring(imageBase64.indexOf(",") + 1);
            }

            // Decode base64 to binary
            byte[] imageBytes = Base64.getDecoder().decode(imageBase64);

            // 2️⃣ Save image to a folder
            String saveDir = "C:/GatepassImages/Foreigner";
            File folder = new File(saveDir);
            if (!folder.exists()) folder.mkdirs();

            String fileName = "ContractLabour_" + request.getParameter("srNo") + ".png";
            File imageFile = new File(saveDir + "/" + fileName);
            try (FileOutputStream fos = new FileOutputStream(imageFile)) {
                fos.write(imageBytes);
            }

            System.out.println("Image saved at: " + imageFile.getAbsolutePath());
            
            // ✅ Extract parameters safely
            int srNo = parseIntSafe(request.getParameter("srNo"), 0);
            String workSite = safeStr(request.getParameter("workSite"));
            String visitingDept = safeStr(request.getParameter("visitingDept"));
            String name = safeStr(request.getParameter("name"));
            String fatherName = safeStr(request.getParameter("fatherName"));
            String officerToMeet = safeStr(request.getParameter("officerToMeet"));
            int age = parseIntSafe(request.getParameter("age"), 0);
            int phone = parseIntSafe(request.getParameter("phone"), 0);
            String localAddress = safeStr(request.getParameter("localAddress"));
            String permanentAddress = safeStr(request.getParameter("permanentAddress"));
            String nationality = safeStr(request.getParameter("nationality"));
            String idcard = safeStr(request.getParameter("idcard"));

       
           

            Database db = new gatepass.Database();
            conn = db.getConnection();
         // ✅ Prepare SQL safely
            String sql = "INSERT INTO GATEPASS_FOREIGNER(SER_NO, WORKSITE, VISIT_DEPT, \r\n"
            		+ "   NAME, FATHER_NAME, AGE, \r\n"
            		+ "   LOCAL_ADDRESS, PERMANENT_ADDRESS, NATIONALITY, \r\n"
            		+ "   VALIDITY_FROM, VALIDITY_TO, PHOTO, \r\n"
            		+ "   UPDATE_DATE, UPDATE_BY, OFFICERTOMEET, \r\n"
            		+ "   PHONE, IDCARD) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);

            
            
            // ✅ Map all params
            ps.setInt(1, srNo);
            ps.setString(2, workSite);
            ps.setString(3, visitingDept);
            ps.setString(4, name);
            ps.setString(5, fatherName);
            ps.setInt(6, age);
            ps.setString(7, localAddress);
            ps.setString(8, permanentAddress);
            ps.setString(9, nationality);
            ps.setDate(10, java.sql.Date.valueOf(request.getParameter("valdity_fromDate")));
            ps.setDate(11, java.sql.Date.valueOf(request.getParameter("valdity_toDate")));


            if (imageBytes != null) {
                ps.setBinaryStream(12, new ByteArrayInputStream(imageBytes), imageBytes.length);
            } else {
                ps.setNull(12, java.sql.Types.BLOB);
            }
            
            // ✅ CommonService for date-time (if available)
            CommonService cs = new CommonService();
            String currentDateTime = cs.selectDateTime();
            ps.setString(13, currentDateTime);
            ps.setString(14, "GatePass");
            ps.setString(15, officerToMeet);
            ps.setInt(16,phone);
            
            ps.setString(17,  idcard);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                System.out.println("✅ Data inserted successfully for SR_NO: " + srNo);
                request.getRequestDispatcher("PrintForeignerGatePass.jsp?srNo=" + srNo)
                       .forward(request, response);
            } else {
                out.println("<h3 style='color:red;'>❌ Data insertion failed. Please try again.</h3>");
            }

        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
            e.printStackTrace(out);
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }

    // 🔹 Utility: Safely parse integers
    private int parseIntSafe(String str, int defaultVal) {
        try {
            if (str == null || str.trim().isEmpty()) return defaultVal;
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }

    // 🔹 Utility: Null-safe string trim
    private String safeStr(String str) {
        return (str == null) ? "" : str.trim();
    }
}
